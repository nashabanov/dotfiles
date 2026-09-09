-- Global transparency defaults.
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.fillchars = {
    vert = " ",
    eob = " ",
    fold = " ",
}

vim.api.nvim_create_autocmd("WinNew", {
    group = vim.api.nvim_create_augroup("FloatingWindowUI", { clear = true }),
    callback = function()
        local win = vim.api.nvim_get_current_win()
        local config = vim.api.nvim_win_get_config(win)

        if config.relative ~= "" then
            vim.wo[win].winblend = 25
        end
    end,
})

vim.diagnostic.config({
    virtual_text = true,
    float = { border = "rounded" },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
        },
    },
})
