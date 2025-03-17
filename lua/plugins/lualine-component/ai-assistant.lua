local codecompanion_progress = require("lualine.component"):extend()

-- init status variable
codecompanion_progress.processing = false
codecompanion_progress.spinner_index = 1
codecompanion_progress.adapter = nil
codecompanion_progress.tool = nil
codecompanion_progress.mode = nil

local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_symbols_len = #spinner_symbols

-- 初始化方法，注册事件监听，捕获 CodeCompanion 请求事件
function codecompanion_progress:init(options)
  codecompanion_progress.super.init(self, options)
  local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        self.processing = true
        self.adapter = request.data.adapter  -- 包含 provider 与 model 信息
        self.tool    = request.data.tool       -- 当前使用的 tool
        self.mode    = request.data.mode       -- 模式，例如 chat 或 agent
      elseif request.match == "CodeCompanionRequestFinished" then
        self.processing = false
        self.adapter = nil
        self.tool    = nil
        self.mode    = nil
      end
    end,
  })
end

-- 每次状态栏更新时调用，返回 spinner 以及额外信息的组合字符串
function codecompanion_progress:update_status()
  if self.processing then
    self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
    local spinner = spinner_symbols[self.spinner_index]

    local adapter_str = ""
    if self.adapter then
      adapter_str = self.adapter.formatted_name or ""
      if self.adapter.model and self.adapter.model ~= "" then
        adapter_str = adapter_str .. "(" .. self.adapter.model .. ")"
      end
    end

    local tool_str = self.tool or ""
    local mode_str = self.mode or "chat"  -- 默认模式为 chat

    return string.format("%s %s %s %s", spinner, adapter_str, tool_str, mode_str)
  else
    return nil
  end
end

return codecompanion_progress
