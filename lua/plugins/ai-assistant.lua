local avante = {
	"yetone/avante.nvim",
	event = "VeryLazy",
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-tree/nvim-web-devicons",
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
	},
	-- build = "make",
	build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false", -- for windows
	opts = {
		provider = "copilot",
		copilot = {
			model = "claude-3.7-sonnet",
		},
		behaviour = {
			auto_focus_sidebar = true,
			auto_suggestions = true, -- Experimental stage
			auto_suggestions_respect_ignore = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			jump_result_buffer_on_finish = false,
			support_paste_from_clipboard = true,
			minimize_diff = true,
			enable_token_counting = true,
			enable_cursor_planning_mode = false,
			enable_claude_text_editor_tool_mode = true,
			use_cwd_as_project_root = false,
		},
		windows = {
			---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
			position = "right",
			wrap = true, -- similar to vim.o.wrap
			width = 30, -- default % based on available width in vertical layout
			height = 30, -- default % based on available height in horizontal layout
			sidebar_header = {
				enabled = true, -- true, false to enable/disable the header
				align = "center", -- left, center, right for title
				rounded = true,
			},
			input = {
				prefix = "> ",
				height = 8, -- Height of the input window in vertical layout
			},
			edit = {
				border = "rounded",
				start_insert = true, -- Start insert mode when opening the edit window
			},
			ask = {
				floating = false, -- Open the 'AvanteAsk' prompt in a floating window
				border = "rounded",
				start_insert = true, -- Start insert mode when opening the ask window
				---@alias AvanteInitialDiff "ours" | "theirs"
				focus_on_apply = "ours", -- which diff to focus after applying
			},
			file_selector = {
				--- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string | fun(params: avante.file_selector.IParams|nil): nil
				provider = "telescope",
				-- Options override for custom providers
				provider_opts = {},
			},
		},
	},
}

-- return { avante }
return { nil }
