local wezterm = require 'wezterm'

-- Tabline settings
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
    options = {
        icons_enabled = true,
        theme = 'Tokyo Night Storm',
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

        tab_active = {
            {
                'process',
                padding = { right = 3, left = 3 },
                max_length = 24,
            },
        },

        tab_inactive = {
            {
                'process',
                padding = { right = 3, left = 3 },
                max_length = 20,
            },
        },
    },
})

local config = wezterm.config_builder()

tabline.apply_to_config(config)

-- Theme
config.color_scheme = 'Tokyo Night Storm'

-- Font
config.font = wezterm.font_with_fallback({
    "Geist Mono",
    "Symbols Nerd Font Mono",
    -- "CommitMono",
    -- "Symbols Nerd Font Mono",
    -- "JetBrainsMono Nerd Font",
    -- "Segoe UI Emoji",
    -- "Cascadia Code"
})
config.font_size = 14


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

config.window_decorations = 'RESIZE'
config.initial_rows = 50
config.initial_cols = 120

config.window_background_opacity = 0.95
config.text_background_opacity = 1

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
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
