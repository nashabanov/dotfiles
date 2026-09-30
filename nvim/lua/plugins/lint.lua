return {
    "mfussenegger/nvim-lint",
    ft = "go",
    dependencies = { "nashabanov/go-context.nvim" },
    config = function()
        require("lsp.go_lint").setup()
    end,
}
