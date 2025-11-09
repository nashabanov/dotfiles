local wezterm = require 'wezterm'

-- Tabline settings
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
    options = {
        icons_enabled = true,
        theme = 'GitHub Dark',
        tabs_enabled = true,

        section_separators = '',
        component_separators = '',
        tab_separators = '',
    },
    sections = {
        tabline_a = {},
        tabline_b = {},
        tabline_c = {},
        tabline_x = {},
        tabline_y = {},
        tabline_z = {},

        -- Активный таб: крупный индекс + имя процесса
        tab_active = {
            {
                'index',
                zero_indexed = false,
                padding = { left = 2, right = 1 },
                fmt = function(idx) return ' ' .. idx .. ' ' end,
            },
            {
                'process',
                padding = { right = 2 },
                max_length = 20,
            },
        },

        tab_inactive = {
            {
                'index',
                zero_indexed = false,
                padding = { left = 1, right = 1 },
            },
            {
                'process',
                padding = { right = 1 },
                max_length = 15,
            },
        },
    },
})

local config = wezterm.config_builder()

tabline.apply_to_config(config)

-- Theme
config.color_scheme = 'GitHub Dark'

-- Font
config.font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "Segoe UI Emoji",
    "Cascadia Code"
})
config.font_size = 14

-- Terminal type
config.default_prog = { 'C:\\Program Files\\PowerShell\\7\\pwsh.exe', '-Nologo' }

-- Tab bar basic
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 64
config.tab_bar_at_bottom = false

-- Window
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}


config.window_decorations = 'TITLE | RESIZE'
config.initial_rows = 50
config.initial_cols = 120

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'EaseIn'
config.cursor_blink_ease_out = 'EaseOut'
config.cursor_thickness = 0.3

-- URL on click or CTRL
config.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

return config
