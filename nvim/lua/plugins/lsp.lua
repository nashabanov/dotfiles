return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        {
            "nashabanov/go-context.nvim",
            -- Newer revision renamed lua/go_context without updating internal imports.
            commit = "39e1ad16473a8430514b6b2f3e2db1bb455742ed",
            config = function()
                require("go_context").setup()
            end,
        },
    },
    config = function()
        require("lsp")
    end,
}
