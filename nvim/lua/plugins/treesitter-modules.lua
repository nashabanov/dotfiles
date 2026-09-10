return {
    "MeanderingProgrammer/treesitter-modules.nvim",
    -- Keep the tested module API alongside the Neovim 0.11-compatible core.
    commit = "290eec96bfc43ed28264661dd30e894a60c4b99c",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        ensure_installed = {
            "python", "go", "gomod", "gosum", "gowork", "lua", "rust",
            "javascript", "typescript", "tsx", "bash", "json", "json5",
            "yaml", "toml", "dockerfile", "proto", "markdown", "markdown_inline",
            "html", "css", "vim", "vimdoc", "query",
        },
        sync_install = false,
        auto_install = false,
        highlight = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<Enter>",
                node_incremental = "<Enter>",
                scope_incremental = "<Tab>",
                node_decremental = "<BS>",
            },
        },
    },
}
