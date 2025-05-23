local miniTest = {
	"echasnovski/mini.test", -- Testing framework for Neovim
	config = true,
	event = "VeryLazy",
}

local neotest = {
	"nvim-neotest/neotest",
	lazy = true,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"antoinemadec/FixCursorHold.nvim",

		-- Adapters
		"nvim-neotest/neotest-plenary",

		-- "nvim-neotest/neotest-python",
		-- "olimorris/neotest-rspec",
		-- "olimorris/neotest-phpunit",
	},
	keys = {
		{
			"<LocalLeader>tn",
			function()
				if vim.bo.filetype == "lua" then
					return require("mini.test").run_at_location()
				end
				require("neotest").run.run()
			end,
			desc = "Neotest: Test nearest",
		},
		{
			"<LocalLeader>tf",
			function()
				if vim.bo.filetype == "lua" then
					return require("mini.test").run_file()
				end
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Neotest: Test file",
		},
		{
			"<LocalLeader>tl",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Neotest: Run last test",
		},
		{
			"<LocalLeader>ts",
			function()
				if vim.bo.filetype == "lua" then
					return require("mini.test").run()
				end
				local neotest = require("neotest")
				for _, adapter_id in ipairs(neotest.run.adapters()) do
					neotest.run.run({ suite = true, adapter = adapter_id })
				end
			end,
			desc = "Neotest: Test suite",
		},
		{
			"<LocalLeader>to",
			function()
				require("neotest").output.open({ short = true })
			end,
			desc = "Neotest: Open test output",
		},
		{
			"<LocalLeader>twn",
			function()
				require("neotest").watch.toggle()
			end,
			desc = "Neotest: Watch nearest test",
		},
		{
			"<LocalLeader>twf",
			function()
				require("neotest").watch.toggle({ vim.fn.expand("%") })
			end,
			desc = "Neotest: Watch file",
		},
		{
			"<LocalLeader>twa",
			function()
				require("neotest").watch.toggle({ suite = true })
			end,
			desc = "Neotest: Watch all tests",
		},
		{
			"<LocalLeader>twa",
			function()
				require("neotest").watch.stop()
			end,
			desc = "Neotest: Stop watching",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-plenary"),
				require("neotest-python")({
					dap = { justMyCode = false },
				}),
				require("neotest-rspec"),
				require("neotest-phpunit"),
			},
			consumers = {
				overseer = require("neotest.consumers.overseer"),
			},
			diagnostic = {
				enabled = false,
			},
			log_level = vim.log.levels.TRACE,
			icons = {
				expanded = "",
				child_prefix = "",
				child_indent = "",
				final_child_prefix = "",
				non_collapsible = "",
				collapsed = "",

				passed = "",
				running = "",
				failed = "",
				unknown = "",
				skipped = "",
			},
			floating = {
				border = "single",
				max_height = 0.8,
				max_width = 0.9,
			},
			summary = {
				mappings = {
					attach = "a",
					expand = { "<CR>", "<2-LeftMouse>" },
					expand_all = "e",
					jumpto = "i",
					output = "o",
					run = "r",
					short = "O",
					stop = "u",
				},
			},
		})
	end,
}

return { miniTest, neotest }
