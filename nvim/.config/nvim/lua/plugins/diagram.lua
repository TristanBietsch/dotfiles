return {
	{
		"3rd/image.nvim",
		build = false,
		opts = {
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" },
				},
			},
			max_width = nil,
			max_height = nil,
			max_width_window_percentage = nil,
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = false,
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = false,
		},
	},
	{
		"3rd/diagram.nvim",
		dependencies = { "3rd/image.nvim" },
		ft = { "markdown" },
		opts = function()
			return {
				events = {
					render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" },
					clear_buffer = { "BufLeave" },
				},
				integrations = {
					require("diagram.integrations.markdown"),
				},
				renderer_options = {
					mermaid = {
						background = "transparent",
						theme = "dark",
						scale = 2,
					},
				},
			}
		end,
		keys = {
			{
				"<leader>md",
				function()
					require("diagram").show_diagram_hover()
				end,
				mode = "n",
				ft = { "markdown" },
				desc = "Show mermaid diagram in new tab",
			},
		},
	},
}
