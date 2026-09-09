local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false,
        config = function()
            require("plugins.neotree")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        priority = 1000,
        config = function()
            require("nvim-treesitter.install").prefer_git = true
            vim.api.nvim_create_autocmd("BufReadPost", {
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local lang = vim.bo[bufnr].filetype
                    if lang ~= "" then
                        pcall(vim.treesitter.start, bufnr, lang)
                    end
                end,
            })
        end,
    },
    require("plugins.treesitter-modules"),
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "williamboman/mason.nvim",
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("lsp")
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require("plugins.cmp")
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
    },
    {
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
    },
    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        priority = 1000,
        config = function()
            require("github-theme").setup({
                options = {
                    transparent = true,
                    terminal_colors = true,
                    styles = {
                        comments = "italic",
                        keywords = "NONE",
                        functions = "NONE",
                        variables = "NONE",
                    },
                },
            })

            vim.cmd.colorscheme("github_dark_dimmed")
        end,
    },
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require("plugins.alpha")
        end,
    },
    {
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
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = true,
            sign_priority = 8,
            keywords = {
                FIX = {
                    icon = " ",
                    color = "error",
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
                },
                TODO = { icon = " ", color = "info" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            },
        }
    },
    require("plugins.which-key"),
    require("plugins.comment"),
    {
        "rcarriga/nvim-notify",
        opts = {
            stages = "fade",
            timeout = 2000,
            render = "compact",
            background_colour = "#000000",
        },
        init = function()
            vim.notify = require("notify")
        end,
    },
    {
        "MunifTanjim/nui.nvim",
        lazy = true,
    },
    {
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
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPost",
        main = "ibl",
    },
    require("plugins.gitsigns"),
    {
        "karb94/neoscroll.nvim",
        opts = {
            hide_cursor = false,
        },
    },
    {
        'nvim-mini/mini.cursorword',
        version = false,
        event = "CursorHold",
        config = function()
            require("mini.cursorword").setup()
        end,
    },
    require("plugins.fff"),
    require("plugins.cinnamon")
})
