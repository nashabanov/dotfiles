return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,
    config = function()
        require("nvim-treesitter.install").prefer_git = true
        vim.api.nvim_create_autocmd("BufReadPost", {
            callback = function()
                local bufnr = vim.api.nvim_get_current_buf()
                local lang = vim.bo[bufnr].filetype
                if lang ~= "" then
                    pcall(vim.treesitter.start, bufnr, lang)
                end
            end,
        })
    end,
}
