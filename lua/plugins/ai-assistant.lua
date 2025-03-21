local vectorCode = {
	"Davidyz/VectorCode",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "VectorCode", -- if you're lazy-loading VectorCode
}

local function create_lualine_component()
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
					self.adapter = request.data.adapter -- 包含 provider 与 model 信息
					self.tool = request.data.tool -- 当前使用的 tool
					self.mode = request.data.mode -- 模式，例如 chat 或 agent
				elseif request.match == "CodeCompanionRequestFinished" then
					self.processing = false
					self.adapter = nil
					self.tool = nil
					self.mode = nil
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
			local mode_str = self.mode or "chat" -- 默认模式为 chat

			return string.format("%s %s %s %s", spinner, adapter_str, tool_str, mode_str)
		else
			return nil
		end
	end

	return codecompanion_progress
end

local codecompanion_opts = {
	language = "Chinese",
	adapters = {
		anthropic = function()
			return require("codecompanion.adapters").extend("anthropic", {
				env = {
					api_key = "cmd:op read op://personal/Anthropic_API/credential --no-newline",
				},
			})
		end,
		copilot = function()
			return require("codecompanion.adapters").extend("copilot", {
				schema = {
					model = {
						default = "claude-3.7-sonnet",
					},
				},
			})
		end,
	},
	-- prompt_library = {},
	strategies = {
		inline = {
			adapter = "copilot",
			keymaps = {
				accept_change = {
					modes = { n = "ca" },
					description = "Accept the suggested change",
					reject_change = {
						modes = { n = "cr" },
						description = "Reject the suggested change",
					},
				},
			},
		},
		chat = {
			adapter = "copilot",
			roles = {
				user = "shrikesama",
			},
			keymaps = {
				send = {
					modes = {
						i = { "<C-s>" },
						n = { "<CR>", "<C-s>" },
					},
				},
				completion = {
					modes = {
						i = "<C-x>",
						n = "<C-x>",
					},
				},
			},
			-- slash_commands = {},
			tools = {
				vectorcode = {
					description = "Run VectorCode to retrieve the project context.",
					callback = function()
						return require("vectorcode.integrations").codecompanion.chat.make_tool()
					end,
				},
				["cmd_runner"] = {
					opts = {
						requires_approval = true,
					},
				},
			},
		},
	},
	display = {
		action_palette = {
			prompt = "Prompt ", -- Prompt used for interactive LLM calls
			provider = "telescope", -- default|telescope|mini_pick
		},
		inline = {
			layout = "vertical", -- vertical|horizontal|buffer
		},
		chat = {
			slash_commands = {
				["file"] = {
					-- Location to the slash command in CodeCompanion
					callback = "strategies.chat.slash_commands.file",
					description = "Select a file using Telescope",
					opts = {
						provider = "telescope", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
						contains_code = true,
					},
				},
			},
			intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
			show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
			separator = "─", -- The separator between the different messages in the chat buffer
			show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
			show_settings = true, -- Show LLM settings at the top of the chat buffer?
			show_token_count = true, -- Show the token count for each response?
			start_in_insert_mode = false, -- Open the chat buffer in insert mode?
			auto_scroll = true,
			window = {
				layout = "float", -- float|vertical|horizontal|buffer
				position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
				border = "single",
				height = 0.8,
				width = 0.45,
				relative = "editor",
				full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
				opts = {
					breakindent = true,
					cursorcolumn = false,
					cursorline = false,
					foldcolumn = "0",
					linebreak = true,
					list = false,
					numberwidth = 1,
					signcolumn = "no",
					spell = false,
					wrap = true,
				},
			},
		},
		diff = {
			provider = "mini_diff",
		},
	},
	opts = {
		log_level = "DEBUG",
	},
}

local codecompanion = {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.diff",
	},
	lazy = true,
	-- cmd = {
	--     "CodeCompanionChat",
	--     "CodeCompanion",
	--     "CodeCompanionAction",
	--     "CodeCompanionCmd",
	-- },
	keys = {
		{
			"<leader>ac",
			function()
				local mode = vim.fn.mode()
				if mode == "v" or mode == "V" then
					-- Visual mode: Use '<,'> range to pass the selection
					vim.cmd("'<,'>CodeCompanionChat")
				else
					-- Normal mode: Just open chat
					vim.cmd("CodeCompanionChat")
				end
			end,
			mode = { "n", "v" },
			desc = "Start AI chat with selection",
		},
		{
			"<leader>aa",
			function()
				local mode = vim.fn.mode()
				if mode == "v" or mode == "V" or mode == "" then
					-- Visual mode: Use '<,'> range to pass the selection
					vim.cmd("'<,'>CodeCompanionAction")
				else
					-- Normal mode: Just open action panel
					vim.cmd("CodeCompanionAction")
				end
			end,
			mode = { "n", "v" },
			desc = "Start AI action with selection",
		},
		{
			"<leader>aw",
			"<cmd>CodeCompanionChat Toggle<CR>",
			mode = { "n", "v" },
			desc = "Open the latest chat buffer",
		},
	},
	opts = function()
		local ok, lualine = pcall(require, "lualine")
		if not ok then
			return codecompanion_opts
		end
		local status_component = create_lualine_component()
		local lua_conf = lualine.get_config()
		table.insert(lua_conf.sections.lualine_x, status_component)
		lualine.setup(lua_conf)
		return codecompanion_opts
	end,
}

-- TODO: add ai completion and add the status to lualine
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


return { vectorCode, codecompanion }
