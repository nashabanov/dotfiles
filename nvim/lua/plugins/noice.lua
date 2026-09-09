return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        lsp = {
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        presets = {
            bottom_search = true,
            command_palette = true,
            long_message_to_split = true,
        },
        views = {
            cmdline_popup = {
                position = { row = "50%", col = "50%" },
                size = { width = 60, height = "auto" },
                border = { style = "rounded" },
                win_options = {
                    winblend = 25,
                },
            },
            popupmenu = {
                relative = "cursor",
                size = { width = "auto", height = 10 },
                border = { style = "rounded" },
                win_options = {
                    winblend = 25,
                },
            },
            hover = {
                border = { style = "rounded" },
                win_options = {
                    winblend = 25,
                },
            },
            message = {
                border = { style = "rounded" },
                win_options = {
                    winblend = 25,
                },
            },
        },
    },
}
