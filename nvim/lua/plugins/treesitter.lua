require'nvim-treesitter.configs'.setup {
    ensure_installed = { 
        "python", "lua", "go", 
        "clojure", "markdown", "markdown_inline", 
        "toml", "yaml", "make", 
    },

    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true
    }
}