local lsp_progress = require("lualine.component"):extend()

function lsp_progress:init(options)
  lsp_progress.super.init(self, options)
  
  -- 创建监听 LSP 进度更新的自动命令组
  vim.api.nvim_create_augroup("lualine_lsp_progress_augroup", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = "lualine_lsp_progress_augroup",
    pattern = "LspProgressStatusUpdated",
    callback = require("lualine").refresh,
  })
end

-- 更新状态栏中显示的 LSP 进度信息
function lsp_progress:update_status()
  return require("lsp-progress").progress()
end

return lsp_progress 
