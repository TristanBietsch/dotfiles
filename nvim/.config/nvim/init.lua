-- Core modules
require("core.options")
require("core.keymaps")
require("core.snippets")

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})

	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
	require("plugins.colorTheme"),
	require("plugins.neoTree"),
	require("plugins.bufferLine"),
	require("plugins.luaLine"),
	require("plugins.treeSitter"),
	require("plugins.telescope"),
	require("plugins.lsp"),
	require("plugins.autoFormatting"),
	require("plugins.autoCompletion"),
	require("plugins.gitSigns"),
	require("plugins.alpha"),
	require("plugins.indentBlankline"),
	require("plugins.misc"),
	require("plugins.toggleTerm"),
	require("plugins.avante"),
	require("plugins.harpoon"),
})
