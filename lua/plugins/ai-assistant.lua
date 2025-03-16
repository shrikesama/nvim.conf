local vectorCode = {
	"Davidyz/VectorCode",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "VectorCode", -- if you're lazy-loading VectorCode
}

local codecompanion = {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.diff",
	},
	opts = {
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
				adapter = "copilot" ,
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
							i = { "<C-CR>", "<C-s>" },
							n = { "<C-CR>", "<C-s>" },
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
	},
}

return { vectorCode, codecompanion }
