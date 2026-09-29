-- Use the installed plugin, but keep persistent test contexts out of user state.
local plugin = vim.env.GO_CONTEXT_PATH or (vim.fn.stdpath("data") .. "/lazy/go-context.nvim")
assert(vim.fn.isdirectory(plugin) == 1, "Install go-context.nvim or set GO_CONTEXT_PATH")
vim.opt.rtp:prepend(plugin)
local state = vim.fn.tempname()
vim.env.XDG_STATE_HOME = state
vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function() vim.fn.delete(state, "rf") end,
})
