return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("telescope").setup({
            defaults = {
                winblend = 25,
                prompt_prefix = "  ",
                selection_caret = "  ",
                entry_prefix = "  ",
                path_display = { "smart" },
                layout_config = {
                    prompt_position = "top",
                    preview_width = 0.55,
                    width = 0.85,
                    height = 0.85,
                },
            },
            pickers = {
                find_files = { theme = "dropdown", previewer = false },
                live_grep = { theme = "dropdown", previewer = false },
            },
        })
    end,
}
