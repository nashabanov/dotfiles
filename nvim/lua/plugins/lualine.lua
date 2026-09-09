return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
        options = {
            theme = "github_dark_dimmed",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            globalstatus = true,
            disabled_filetypes = {
                statusline = { "alpha", "neo-tree" },
            },
        },
        sections = {
            lualine_a = {
                {
                    "mode",
                    icon = "󰘳 ",
                    fmt = function(str)
                        local modes = {
                            ["NORMAL"] = "N",
                            ["INSERT"] = "I",
                            ["VISUAL"] = "V",
                            ["V-LINE"] = "V",
                            ["V-BLOCK"] = "V",
                            ["SELECT"] = "S",
                            ["COMMAND"] = "C",
                            ["REPLACE"] = "R",
                            ["TERMINAL"] = "T",
                        }
                        return modes[str] or str:sub(1, 1)
                    end,
                    padding = { left = 1, right = 1 },
                },
            },
            lualine_b = {
                {
                    "branch",
                    icon = "",
                    color = { fg = "#539bf5" },
                },
                {
                    "diff",
                    symbols = { added = "+", modified = "~", removed = "-" },
                    color_added = { fg = "#57ab5a" },
                    color_modified = { fg = "#c69026" },
                    color_removed = { fg = "#f47067" },
                },
            },
            lualine_c = {
                {
                    "filename",
                    path = 1,
                    symbols = {
                        modified = "●",
                        readonly = "🔒",
                        unnamed = "[No Name]",
                    },
                    color = { fg = "#adbac7" },
                },
            },
            lualine_x = {
                {
                    "diagnostics",
                    sources = { "nvim_lsp" },
                    symbols = {
                        error = " ",
                        warn = " ",
                        info = " ",
                        hint = " ",
                    },
                    color_error = { fg = "#f47067" },
                    color_warn = { fg = "#c69026" },
                    color_info = { fg = "#539bf5" },
                    color_hint = { fg = "#768390" },
                    padding = { left = 1, right = 1 },
                },
                {
                    "filetype",
                    icon_only = true,
                    padding = { left = 1, right = 1 },
                },
            },
            lualine_y = {},
            lualine_z = {
                {
                    "location",
                    fmt = function(str)
                        return str
                    end,
                    color = { fg = "#768390" },
                },
            },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
    },
}
