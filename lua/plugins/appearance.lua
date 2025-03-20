local theme = {
	"scottmckendry/cyberdream.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local cyberdream = require("cyberdream")
		cyberdream.setup({
			transparent = true,

			-- Enable italics comments
			italic_comments = true,

			-- Replace all fillchars with ' ' for the ultimate clean look
			hide_fillchars = true,

			-- Modern borderless telescope theme - also applies to fzf-lua
			borderless_telescope = true,

			-- Set terminal colors used in `:terminal`
			terminal_colors = true,

			-- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
			cache = false,

			theme = {
				-- variant = "auto", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
				variant = "dark", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
				saturation = 1, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)
			},
		})
		vim.cmd.colorscheme("cyberdream")
	end,
}

local notice = {
	"folke/noice.nvim",
	event = "VeryLazy",
	config = function()
		require("noice").setup({
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					opts = { skip = true },
				},
			},
			presets = {
				bottom_search = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			cmdline = {
				view = "cmdline",
			},
			views = {
				mini = {
					win_options = {
						winblend = 0,
					},
				},
			},
		})
	end,
}

local nvim_navic = {
	"smiteshp/nvim-navic",
	config = function()
		require("nvim-navic").setup({
			lsp = {
				auto_attach = true,
				-- priority order for attaching LSP servers
				-- to the current buffer
				preference = {
					"html",
					"templ",
				},
			},
			separator = " 󰁔 ",
		})
	end,
}

-- lualine setting
local lualine = {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"olimorris/codecompanion.nvim",
	},
	config = function()
		local lualine = require("lualine")
		--- local lazy_status = require("lazy.status") -- to configure lazy pending updates count
		local buffer_status = {
			"buffers",
			show_filename_only = true, -- Shows shortened relative path when set to false.
			hide_filename_extension = true, -- Hide filename extension when set to true.
			show_modified_status = true, -- Shows indicator when the buffer is modified.

			mode = 4, -- 0: Shows buffer name
			-- 1: Shows buffer index
			-- 2: Shows buffer name + buffer index
			-- 3: Shows buffer number
			-- 4: Shows buffer name + buffer number

			max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
			-- it can also be a function that returns
			-- the value of `max_length` dynamically.
		}

		local window_status = {
			"windows",
			mod = 2,
		}

		local tabs_status = {
			"tabs",
			tab_max_length = 40, -- Maximum width of each tab. The content will be shorten dynamically (example: apple/orange -> a/orange)
			max_length = vim.o.columns / 3, -- Maximum width of tabs component.

			path = 0, -- 0: just shows the filename
			-- 1: shows the relative path and shorten $HOME to ~
			-- 2: shows the full path
			-- 3: shows the full path and shorten $HOME to ~
		}

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				theme = "auto",
			},
			tabline = {
				lualine_a = { buffer_status },
				lualine_y = { window_status },
				lualine_z = { tabs_status },
			},
			sections = {
				lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
			},
		})
	end,
}

-- local lsp_progress = {
-- 	"linrongbin16/lsp-progress.nvim",
-- 	config = function()
-- 		require("lsp-progress").setup({
-- 			series_format = function(title, message, percentage, done)
-- 				local builder = {}
-- 				local has_title = false
-- 				local has_message = false
-- 				if title and title ~= "" then
-- 					table.insert(builder, title)
-- 					has_title = true
-- 				end
-- 				if message and message ~= "" then
-- 					table.insert(builder, message)
-- 					has_message = true
-- 				end
-- 				if percentage and (has_title or has_message) then
-- 					table.insert(builder, string.format("(%.0f%%%%)", percentage))
-- 				end
-- 				if done and (has_title or has_message) then
-- 					table.insert(builder, "- done")
-- 				end
-- 				-- return table.concat(builder, " ")
-- 				return { msg = table.concat(builder, " "), done = done }
-- 			end,
-- 			client_format = function(client_name, spinner, series_messages)
-- 				if #series_messages == 0 then
-- 					return nil
-- 				end
-- 				local builder = {}
-- 				local done = true
-- 				for _, series in ipairs(series_messages) do
-- 					if not series.done then
-- 						done = false
-- 					end
-- 					table.insert(builder, series.msg)
-- 				end
-- 				if done then
-- 					-- replace the check mark once done
-- 					spinner = "%#LspProgressMessageCompleted#✓%*"
-- 				end
-- 				return "[" .. client_name .. "] " .. spinner .. " " .. table.concat(builder, ", ")
-- 			end,
-- 		})
-- 	end,
-- }

local lualine_new = {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "echasnovski/mini.icons" },
	opts = function()

		local utils = require("core.utils")
		local copilot_colors = {
			[""] = utils.get_hlgroup("Comment"),
			["Normal"] = utils.get_hlgroup("Comment"),
			["Warning"] = utils.get_hlgroup("DiagnosticError"),
			["InProgress"] = utils.get_hlgroup("DiagnosticWarn"),
		}

		local filetype_map = {
			lazy = { name = "lazy.nvim", icon = "💤" },
			minifiles = { name = "minifiles", icon = "🗂️ " },
			snacks_terminal = { name = "terminal", icon = "🐚" },
			mason = { name = "mason", icon = "🔨" },
			TelescopePrompt = { name = "telescope", icon = "🔍" },
			["copilot-chat"] = { name = "copilot", icon = "🤖" },
		}

		local buffer_status = {
			"buffers",
			show_filename_only = true, -- Shows shortened relative path when set to false.
			hide_filename_extension = true, -- Hide filename extension when set to true.
			show_modified_status = true, -- Shows indicator when the buffer is modified.

			mode = 4, -- 0: Shows buffer name
			-- 1: Shows buffer index
			-- 2: Shows buffer name + buffer index
			-- 3: Shows buffer number
			-- 4: Shows buffer name + buffer number

			max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
			-- it can also be a function that returns the value of `max_length` dynamically.
		}

		local window_status = {
			"windows",
			mod = 2,
		}

		local tabs_status = {
			"tabs",
			tab_max_length = 40, -- Maximum width of each tab. The content will be shorten dynamically (example: apple/orange -> a/orange)
			max_length = vim.o.columns / 3, -- Maximum width of tabs component.

			path = 0, -- 0: just shows the filename
			-- 1: shows the relative path and shorten $HOME to ~
			-- 2: shows the full path
			-- 3: shows the full path and shorten $HOME to ~
		}

		local mode_statues = {
			"mode",
			icon = "",
			fmt = function(mode)
				return mode:lower()
			end,
		}

		local git_branch = {
			"branch",
			icon = "",
			fmt = function(branch)
				return branch
			end,
		}

		local diagnostics = {
			"diagnostics",
			symbols = {
				error = " ",
				warn = " ",
				info = " ",
				hint = "󰝶 ",
			},
		}

		local file_icon = {
			function()
				local devicons = require("nvim-web-devicons")
				local ft = vim.bo.filetype
				local icon
				if filetype_map[ft] then
					return " " .. filetype_map[ft].icon
				end
				if icon == nil then
					icon = devicons.get_icon(vim.fn.expand("%:t"))
				end
				if icon == nil then
					icon = devicons.get_icon_by_filetype(ft)
				end
				if icon == nil then
					icon = " 󰈤"
				end

				return icon .. " "
			end,
			color = function()
				local _, hl = require("nvim-web-devicons").get_icon(vim.fn.expand("%:t"))
				if hl then
					return hl
				end
				return utils.get_hlgroup("Normal")
			end,
			separator = "",
			padding = { left = 0, right = 0 },
		}

		local filename = {
			"filename",
			padding = { left = 0, right = 0 },
			fmt = function(name)
				if filetype_map[vim.bo.filetype] then
					return filetype_map[vim.bo.filetype].name
				else
					return name
				end
			end,
		}

		local buffer_counter = {
			function()
				local buffer_count = require("core.utils").get_buffer_count()

				return "+" .. buffer_count - 1 .. " "
			end,
			cond = function()
				return require("core.utils").get_buffer_count() > 1
			end,
			color = utils.get_hlgroup("Operator", nil),
			padding = { left = 0, right = 1 },
		}

		local tab_counter = {
			function()
				local tab_count = vim.fn.tabpagenr("$")
				if tab_count > 1 then
					return vim.fn.tabpagenr() .. " of " .. tab_count
				end
			end,
			cond = function()
				return vim.fn.tabpagenr("$") > 1
			end,
			icon = "󰓩",
			color = utils.get_hlgroup("Special", nil),
		}

		local navic = {
			function()
				return require("nvim-navic").get_location()
			end,
			cond = function()
				return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
			end,
			color = utils.get_hlgroup("Comment", nil),
		}

		local notice_section = {
			---@diagnostic disable: undefined-field
			require("noice").api.status.mode.get,
			cond = function()
				local ignore = {
					"-- INSERT --",
					"-- TERMINAL --",
					"-- VISUAL --",
					"-- VISUAL LINE --",
					"-- VISUAL BLOCK --",
				}
				local mode = require("noice").api.status.mode.get()
				return require("noice").api.status.mode.has() and not vim.tbl_contains(ignore, mode)
			end,
			color = utils.get_hlgroup("Comment"),
			---@diagnostic enable: undefined-field
		}

		local copilot_status = {
			function()
				local icon = " "
				local status = require("copilot.api").status.data
				return icon .. (status.message or "")
			end,
			cond = function()
				local ok, clients = pcall(vim.lsp.get_clients, { name = "copilot", bufnr = 0 })
				return ok and #clients > 0
			end,
			color = function()
				if not package.loaded["copilot"] then
					return
				end
				local status = require("copilot.api").status.data
				return copilot_colors[status.status] or copilot_colors[""]
			end,
		}

		local ai_assistant_status = require("plugins.lualine-component.ai-assistant")
		local lsp_progress_status = require("plugins.lualine-component.lsp-progress")

		return {
			options = {
				component_separators = { left = " ", right = " " },
				section_separators = { left = " ", right = " " },
				theme = "auto",
				globalstatus = true,
				disabled_filetypes = { statusline = { "dashboard", "alpha", "" } },
			},
			tabline = {
				lualine_a = { buffer_status },
				lualine_y = { window_status },
				lualine_z = { tabs_status, tab_counter },
			},
			-- winbar = {
			-- 	lualine_b = { navic },
			-- },
			sections = {
				lualine_a = { git_branch, { "diff" } },
				lualine_b = { mode_statues },
				lualine_c = { diagnostics, lsp_progress_status },
				lualine_x = { copilot_status, ai_assistant_status },
				lualine_y = { "progress", "encoding", "fileformat", "filetype" },
			},
		}
	end,
}

local dressing = {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
}

return { theme, nvim_navic, notice, lsp_progress, lualine_new, dressing }
