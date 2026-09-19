return {
    "mfussenegger/nvim-lint",
    ft = "go",
    config = function()
        require("lsp.go_lint").setup()
    end,
}
