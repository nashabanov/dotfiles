return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        {
            "nashabanov/go-context.nvim",
            config = function()
                require("go-context").setup()
            end,
        },
    },
    config = function()
        require("lsp")
    end,
}
