return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- Last revision before Neovim 0.11 support was removed.
    commit = "90cd6580e720caedacb91fdd587b747a6e77d61f",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        -- This parser set uses JSON5 for JSON with comments.
        vim.treesitter.language.register("json5", "jsonc")
    end,
}
