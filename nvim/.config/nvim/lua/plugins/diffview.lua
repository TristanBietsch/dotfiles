-- Diff review UI. Pairs with claudecode.nvim and gitsigns: open a side-by-side
-- view of working-tree changes, walk per-file hunks, or scrub through a file's
-- git history. Lazy-loaded on its commands so it adds nothing to startup.
return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewFileHistory",
	},
	opts = {
		enhanced_diff_hl = true,
		view = {
			default = { layout = "diff2_horizontal" },
			merge_tool = { layout = "diff3_mixed" },
			file_history = { layout = "diff2_horizontal" },
		},
	},
	keys = {
		{ "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Diff: open working-tree review" },
		{ "<leader>da", "<cmd>DiffviewOpen<cr>", desc = "Diff: all uncommitted (agent) changes" },
		{ "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diff: close review" },
		{ "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: history of current file" },
		{ "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "Diff: history of all files" },
	},
}
