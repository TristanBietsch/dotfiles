-- Bridges nvim to an external Claude Code session (running in a separate tmux
-- pane/window). Runs a WebSocket/MCP server inside nvim and drops a lockfile in
-- ~/.claude/ide/, which Claude Code auto-discovers. Edits arrive as diffs in
-- nvim for review; buffers stay in sync with on-disk state.
return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	event = "VeryLazy", -- start the WebSocket server eagerly so Claude can discover it
	opts = {
		terminal = {
			-- Claude runs in a separate tmux pane, not embedded in nvim.
			-- Switch to "auto" (or "external" + external_terminal_cmd) if you ever want
			-- :ClaudeCode to spawn it for you.
			provider = "none",
		},
		diff_opts = {
			layout = "vertical",
			auto_close_on_accept = true,
		},
	},
	keys = {
		{ "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current buffer" },
		{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
		{ "<leader>ct", "<cmd>ClaudeCodeTreeAdd<cr>", ft = { "neo-tree" }, desc = "Claude: add file from tree" },
		{ "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff (yes)" },
		{ "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff (no)" },
		{ "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
	},
}
