return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.cmd("Lazy load markdown-preview.nvim")
		vim.fn["mkdp#util#install"]()
	end,
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
		vim.g.mkdp_auto_close = 0
		vim.g.mkdp_theme = "dark"
	end,
	keys = {
		{
			"<leader>mp",
			"<cmd>MarkdownPreviewToggle<cr>",
			ft = "markdown",
			desc = "Toggle markdown preview (browser)",
		},
	},
}
