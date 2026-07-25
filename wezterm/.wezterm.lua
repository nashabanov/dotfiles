local wezterm = require 'wezterm'
local theme = 'Github Dark (Gogh)'

-- Tabline settings
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
    options = {
        icons_enabled = true,
        theme = theme,
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
config.color_scheme = theme

-- Font
config.font = wezterm.font_with_fallback({
    { family = "Geist Mono", weight = "Regular" },
    "Symbols Nerd Font Mono",
})
config.font_size = 13.5
config.line_height = 1.25
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"
config.underline_thickness = "1pt"
config.front_end = "WebGpu"


-- Tab bar basic
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 64
config.tab_bar_at_bottom = false

-- Window
config.window_padding = {
    left = 12,
    right = 12,
    top = 12,
    bottom = 12,
}

config.window_decorations = 'RESIZE'
config.initial_rows = 50
config.initial_cols = 120

config.window_background_opacity = 0.96
config.text_background_opacity = 1
config.macos_window_background_blur = 25

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'EaseIn'
config.cursor_blink_ease_out = 'EaseOut'
config.cursor_thickness = 0.25

-- URL on click or CTRL
config.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

config.keys = {
    { key = 'h', mods = 'CTRL',       action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'CTRL',       action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'CTRL',       action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'CTRL',       action = wezterm.action.ActivatePaneDirection 'Right' },

    { key = 's', mods = 'CTRL',       action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'v', mods = 'CTRL',       action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

    { key = 'q', mods = 'CTRL',       action = wezterm.action.CloseCurrentPane { confirm = false } },

    { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 3 } },
    { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 3 } },
    { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 3 } },
    { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 3 } },

    { key = 'z', mods = 'CTRL',       action = wezterm.action.TogglePaneZoomState },
}


return config
