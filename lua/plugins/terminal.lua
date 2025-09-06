local terminal = {
  name = "custom-terminal",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  config = function()
    local term = require('scripts.terminal')
    
    -- Setup the terminal module
    term.setup({
      split_default = 'h',
      name_formatter = function(cwd, rel, id)
        return string.format("term[%s] · #%d", rel, id)
      end,
      refresh_events = { 'BufEnter', 'TermEnter', 'CursorHold', 'FocusGained' }
    })
  end,
  keys = {
    { "<leader>tf", function() require('scripts.terminal').term_new('h') end, desc = "Horizontal terminal" },
    { "<leader>tt", function() require('scripts.terminal').term_new('h') end, desc = "New terminal" },
    { "<leader>tv", function() require('scripts.terminal').term_new('v') end, desc = "Vertical terminal" },
    { "<leader>ts", function() require('scripts.terminal').term_new('h') end, desc = "Horizontal terminal" },
    { "<leader>tl", function() require('scripts.terminal').term_select() end, desc = "Terminal select" },
  },
}

return { terminal }