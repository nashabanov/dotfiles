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
            padding = 0,
            indent_size = 2,
            with_markers = true,
            with_expanders = true,
            indent_marker = "│",
            last_indent_marker = "└",
            expander_collapsed = "",
            expander_expanded = "",
        },
        icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            default = "",
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
        width = 30,
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
        follow_current_file = { enabled = true, },
        use_libuv_file_watcher = true,
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "neo-tree",
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

local function setup_neotree_ui()
    local h1 = vim.api.nvim_set_hl
    h1(0, "NeoTreeNormal", { link = "Normal" })
    h1(0, "NeoTreeNormalNC", { link = "NormalNC" })
    h1(0, "NeoTreeCursorLine", { link = "CursorLine" })

    h1(0, "NeoTreeDirectoryName", { link = "Directory", bold = true })
    h1(0, "NeoTreeRootName", { link = "Title", bold = true })
    h1(0, "NeoTreeFileNameOpened", { link = "Bold", bold = true, underline = true })

    h1(0, "NeoTreeIndentMarker", { link = "NonText" })
    h1(0, "NeoTreeWinSeparator", { link = "WinSeparator" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_neotree_ui,
})

setup_neotree_ui()
