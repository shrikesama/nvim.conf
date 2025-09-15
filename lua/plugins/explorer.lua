local function open_win_config_func()
    local scr_w = vim.opt.columns:get()
    local scr_h = vim.opt.lines:get()
    -- Set floating window to 2/3 of the current screen size
    local tree_w = math.floor(scr_w * 2 / 3)
    local tree_h = math.floor(scr_h * 2 / 3)
    return {
        border = "double",
        relative = "editor",
        width = tree_w,
        height = tree_h,
        col = (scr_w - tree_w) / 2,
        row = (scr_h - tree_h) / 2
    }
end

local nvim_tree = {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local nvimtree = require("nvim-tree")

        -- recommended settings from nvim-tree documentation
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        nvimtree.setup({
            view = {
                signcolumn = "yes",
                float = {
                    enable = true,
                    open_win_config = open_win_config_func
                },
                cursorline = false
            },
            modified = {
                enable = true
            },
            -- change folder arrow icons
            renderer = {
                indent_markers = {
                    enable = true,
                },
                icons = {
                    glyphs = {
                        folder = {
                            arrow_closed = "", -- arrow when folder is closed
                            arrow_open = "", -- arrow when folder is open
                        },
                    },
                },
            },
            -- disable window_picker for
            -- explorer to work well with
            -- window splits
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

        -- set keymaps
        local keymap = vim.keymap                                                                   -- for conciseness

        keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
        keymap.set(
            "n",
            "<leader>ef",
            "<cmd>NvimTreeFindFileToggle<CR>",
            { desc = "Toggle file explorer on current file" }
        )                                                                                               -- toggle file explorer on current file
        keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
        keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })   -- refresh file explorer
    end,
}

return { nvim_tree }
