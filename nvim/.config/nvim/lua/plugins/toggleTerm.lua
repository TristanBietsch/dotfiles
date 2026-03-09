return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			size = 15, -- height of bottom terminal
			direction = "horizontal", -- bottom split like VS Code
			open_mapping = [[<C-\>]], -- toggle with Ctrl+\
			shade_terminals = true,
			start_in_insert = true,
		})
	end,
}
