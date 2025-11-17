require('nvim-treesitter.configs').setup({
    ensure_installed = {
        "python", "lua", "go",
        "clojure", "markdown", "markdown_inline",
        "toml", "yaml", "make",
        "bash", "json", "dockerfile", "git_config", "gitignore",
    },

    modules = {},
    ignore_install = {},

    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<S-CR>",
            node_decremental = "<BS>",
        },
    },
})
