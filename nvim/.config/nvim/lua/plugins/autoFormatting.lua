return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true })
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			python = { "ruff_format" },
			go = { "gofmt" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			html = { "prettier" },
			astro = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			sass = { "prettier" },
			rust = { "rustfmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			lua = { "stylua" },
			elixir = { "mix" },
			tex = { "latexindent" },
			latex = { "latexindent" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
