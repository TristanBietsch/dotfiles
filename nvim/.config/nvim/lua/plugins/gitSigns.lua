-- Adds git related signs to the gutter, as well as utilities for managing changes.
-- Doubles as the live "what did the agent just change" view: hunks update as
-- files reload from disk, and can be previewed or reverted per hunk.
return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		signs_staged = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		numhl = true,
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "Git: next hunk")
			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "Git: prev hunk")

			map("n", "<leader>gp", gs.preview_hunk, "Git: preview hunk")
			map("n", "<leader>gr", gs.reset_hunk, "Git: reset hunk (revert agent change)")
			map("n", "<leader>ga", gs.stage_hunk, "Git: stage hunk")
			map("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, "Git: blame line")
			map("n", "<leader>gd", gs.toggle_deleted, "Git: toggle deleted lines")
			map("n", "<leader>gl", gs.toggle_linehl, "Git: toggle changed-line highlight")
			map("n", "<leader>gD", gs.diffthis, "Git: diff this vs index")
		end,
	},
}
