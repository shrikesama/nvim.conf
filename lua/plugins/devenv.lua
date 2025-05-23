local remote_nvim = {
	"amitds1997/remote-nvim.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- For standard functions
		"MunifTanjim/nui.nvim", -- To build the plugin UI
		"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
	},
	config = true,
}

return { remote_nvim }
