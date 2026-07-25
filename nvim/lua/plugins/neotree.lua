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
            padding = 1,
            indent_size = 2,
            with_markers = true,
            with_expanders = true,
            indent_marker = "│",
            last_indent_marker = "└",
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
        },
        icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            default = "",
            folder_empty_open = "",
            use_filtered_colors = false,
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
        width = 32,
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
                ".DS_Store"
            },
        },
        follow_current_file = { enabled = true, leave_dirs_open = false },
        use_libuv_file_watcher = true,
        bind_to_cwd = true,
        cwd_target = {
            sidebar = "tab",
            current = "window",
        },
    },
    buffers = {
        follow_current_file = { enabled = true, leave_open = false },
        show_unloaded = true,
    },
    source_selector = {
        winbar = false,
        statusline = false,
        truncation_character = " "
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "neo-tree",
    callback = function()
        vim.opt_local.cursorline = true
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

local function setup_neotree_ui()
    local h = vim.api.nvim_set_hl

    h(0, "NeoTreeNormal", { bg = "NONE", fg = "#adbac7" })
    h(0, "NeoTreeNormalNC", { bg = "NONE", fg = "#adbac7" })
    h(0, "NeoTreeEndOfBuffer", { bg = "NONE", fg = "NONE" })

    -- Курсор и выделение
    h(0, "NeoTreeCursorLine", { bg = "#31363d", bold = false })
    h(0, "NeoTreeWinSeparator", { bg = "NONE", fg = "#31363d" })

    -- Заголовки и директории
    h(0, "NeoTreeRootName", { fg = "#f5f5f7", bold = true })
    h(0, "NeoTreeDirectoryName", { fg = "#539bf5", bold = false })
    h(0, "NeoTreeDirectoryIcon", { fg = "#539bf5", bold = false })

    -- Файлы
    h(0, "NeoTreeFileName", { fg = "#adbac7" })
    h(0, "NeoTreeFileNameOpened", { fg = "#539bf5", underline = false, italic = true })
    h(0, "NeoTreeFileIcon", { fg = "#768390" })

    -- Модифицированные файлы
    h(0, "NeoTreeModified", { fg = "#f47067", bold = false })

    -- Indent markers
    h(0, "NeoTreeIndentMarker", { fg = "#444c56" })
    h(0, "NeoTreeExpander", { fg = "#768390" })
    h(0, "NeoTreeExpanderCollapsed", { fg = "#768390" })

    -- Git статусы (приглушенные цвета)
    h(0, "NeoTreeGitAdded", { fg = "#57ab5a" })
    h(0, "NeoTreeGitConflict", { fg = "#f47067" })
    h(0, "NeoTreeGitDeleted", { fg = "#f47067" })
    h(0, "NeoTreeGitIgnored", { fg = "#545d68" })
    h(0, "NeoTreeGitModified", { fg = "#c69026" })
    h(0, "NeoTreeGitRenamed", { fg = "#986ee2" })
    h(0, "NeoTreeGitStaged", { fg = "#57ab5a" })
    h(0, "NeoTreeGitUnstaged", { fg = "#f47067" })
    h(0, "NeoTreeGitUntracked", { fg = "#768390" })
    h(0, "NeoTreeGitStatus", { fg = "#768390" })

    -- Special items
    h(0, "NeoTreeSymbolicLinkTarget", { fg = "#986ee2", italic = true })
    h(0, "NeoTreeTitleBar", { bg = "#22272e", fg = "#f5f5f7", bold = true })

    h(0, "NeoTreeNormal", { link = "Normal" })
    h(0, "NeoTreeNormalNC", { link = "NormalNC" })
    h(0, "NeoTreeCursorLine", { link = "CursorLine" })

    h(0, "NeoTreeDirectoryName", { link = "Directory", bold = true })
    h(0, "NeoTreeRootName", { link = "Title", bold = true })
    h(0, "NeoTreeFileNameOpened", { link = "Bold", bold = true, underline = true })

    h(0, "NeoTreeIndentMarker", { link = "NonText" })
    h(0, "NeoTreeWinSeparator", { link = "WinSeparator" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_neotree_ui,
})

setup_neotree_ui()
