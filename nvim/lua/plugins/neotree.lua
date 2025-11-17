vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
            [vim.diagnostic.severity.HINT] = '󰌵 ',
        },
    }
})

require("neo-tree").setup({
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_normal_mode_for_inputs = false,
    default_component_configs = {
        indent = {
            with_markers = false,
            indent_size = 2,
            padding = 1,
            with_expanders = true,
            expander_collapsed = "",
            expander_expanded = "",
        },
        icon = {
            folder_closed = "▸",
            folder_open = "▾",
            folder_empty = "▸",
            default = "•",
        },
        git_status = {
            symbols = {
                added     = "+",
                modified  = "~",
                deleted   = "-",
                renamed   = "→",
                untracked = "?",
                ignored   = "◌",
                unstaged  = "✗",
                staged    = "✓",
                conflict  = "!",
            },
        },
    },
    window = {
        width = 35,
        position = "left",
        mappings_options = {
            noremap = true,
            nowait = true,
        },
    },
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_by_name = {
                ".git",
                "node_modules",
                "__pycache__",
            },
        },
        follow_current_file = {
            enabled = true,
        },
        use_libuv_file_watcher = true,
    },
})

vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "NONE", fg = "NONE" })
