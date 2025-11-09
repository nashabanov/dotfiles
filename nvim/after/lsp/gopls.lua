vim.lsp.config("gopls", {
    settings = {
        gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            completeUnimported = true,
            usePlaceholders = true,
            gofumpt = true,
        },
    },
    filetypes = { "go" },
    single_file_support = true,
})
