local toggleterm = {
	"akinsho/toggleterm.nvim",
	version = "*",
	lazy = true,
	keys = {
		{ "<Leader>sf", "<cmd>ToggleTerm direction=float<CR>", desc = "open terminal float" },
	},
	opts = function()
		function _G.set_terminal_keymaps()
			local opts = { noremap = true }
			vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
		end

		vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

		return {
			-- size can be a number or function which is passed the current terminal
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			open_mapping = [[<F12>]],
			---@diagnostic disable-next-line: unused-local
			on_open = function(term) end,
			---@diagnostic disable-next-line: unused-local
			on_close = function(term) end,
			highlights = {
				-- highlights which map to a highlight group name and a table of it's values
				-- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
				Normal = {
					link = "Normal",
				},
				NormalFloat = {
					link = "Normal",
				},
				FloatBorder = {
					-- guifg = <VALUE-HERE>,
					-- guibg = <VALUE-HERE>,
					link = "FloatBorder",
				},
			},
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
			start_in_insert = true,
			insert_mappings = true, -- whether or not the open mapping applies in insert mode
			persist_size = true,
			direction = "float", -- | 'horizontal' | 'window' | 'float',
			close_on_exit = true, -- close the terminal window when the process exits
			shell = vim.o.shell, -- change the default shell
			-- This field is only relevant if direction is set to 'float'
			float_opts = {
				border = "curved", -- single/double/shadow/curved
				width = math.floor(0.7 * vim.fn.winwidth(0)),
				height = math.floor(0.8 * vim.fn.winheight(0)),
				winblend = 0,
			},
			winbar = {
				enabled = true,
			},
		}
	end,
}

return { toggleterm }
