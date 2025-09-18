local preview = require("utils.nvim_tree_preview")

local layout_opts = {
  height_ratio = 0.72,
  tree_ratio = 0.25,
  preview_ratio = 0.5,
  gap = 2,
  min_tree_width = 30,
  min_preview_width = 56,
  border = "rounded",
}

local function open_win_config_func()
  local scr_w = vim.opt.columns:get()
  local scr_h = vim.opt.lines:get()
  local height = math.max(math.floor(scr_h * layout_opts.height_ratio), 20)
  local tree_w = math.max(math.floor(scr_w * layout_opts.tree_ratio), layout_opts.min_tree_width)
  local preview_w = math.max(math.floor(scr_w * layout_opts.preview_ratio), layout_opts.min_preview_width)
  local total = tree_w + preview_w + layout_opts.gap

  if total > scr_w - 2 then
    local available = scr_w - layout_opts.gap - 2
    tree_w = math.max(math.floor(available * layout_opts.tree_ratio), layout_opts.min_tree_width)
    preview_w = available - tree_w
    if preview_w < layout_opts.min_preview_width then
      preview_w = layout_opts.min_preview_width
      tree_w = available - preview_w
    end
    if tree_w < layout_opts.min_tree_width then
      tree_w = layout_opts.min_tree_width
      preview_w = available - tree_w
    end
    total = tree_w + preview_w + layout_opts.gap
  end

  local col = math.floor((scr_w - total) / 2)
  if col < 0 then
    col = 0
  end
  local row = math.floor((scr_h - height) / 2)
  if row < 0 then
    row = 0
  end

  preview.set_layout({
    tree = {
      width = tree_w,
      height = height,
      row = row,
      col = col,
    },
    preview = {
      width = preview_w,
      height = height,
      row = row,
      col = col + tree_w + layout_opts.gap,
    },
  })

  return {
    border = layout_opts.border,
    relative = "editor",
    width = tree_w,
    height = height,
    col = col,
    row = row,
  }
end

local function on_attach(bufnr)
  local api = require("nvim-tree.api")
  api.config.mappings.default_on_attach(bufnr)
  preview.attach(api, bufnr)

  vim.keymap.set("n", "<CR>", function()
    api.node.open.edit()
    preview.sync_tree()
  end, { buffer = bufnr, desc = "Open file" })
  vim.keymap.set("n", "<M-CR>", preview.focus, { buffer = bufnr, desc = "Focus nvim-tree preview" })
  vim.keymap.set("n", "<Esc>", preview.close_tree, { buffer = bufnr, desc = "Close nvim-tree" })
end

local nvim_tree = {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")
    preview.setup({
      border = layout_opts.border,
      winblend = 0,
      max_file_size = 300 * 1024,
    })

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      on_attach = on_attach,
      view = {
        signcolumn = "yes",
        float = {
          enable = true,
          open_win_config = open_win_config_func,
        },
        cursorline = false,
      },
      modified = {
        enable = true,
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
          },
        },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { ".DS_Store" },
      },
      git = {
        ignore = false,
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>ee", preview.toggle_tree, { desc = "Toggle file explorer" })
    keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
    keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
    keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
  end,
}

return { nvim_tree }
