local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("plugins.treesitter"),
	require("plugins.treesitter-modules"),
	require("plugins.lazydev"),
	require("plugins.lsp"),
	require("plugins.lint"),
	require("plugins.cmp"),
	require("plugins.autopairs"),
	require("plugins.snacks"),
	require("plugins.theme"),
	require("plugins.lualine"),
	require("plugins.todo-comments"),
	require("plugins.which-key"),
	require("plugins.comment"),
	require("plugins.nui"),
	require("plugins.noice"),
	require("plugins.gitsigns"),
	require("plugins.cursorword"),
	require("plugins.fff"),
})
