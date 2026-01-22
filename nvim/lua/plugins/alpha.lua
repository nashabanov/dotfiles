local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Крупный, милый, мемный кот (ASCII)
local ascii_art = {
    "  ┌───────────────────────┐",
    "  │        /\\_/\\          │",
    "  │       ( •ᴗ• )         │",
    "  │        /   \\          │",
    "  │                       │",
    "  │>_ git commit -m \"meow\"│",
    "  │                       │",
    "  └───────────────────────┘",
}
-- Кнопки — используем иконки Nerd Fonts (можно заменить на символы, если не установлены)
dashboard.section.buttons.val = {
    dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
    dashboard.button("e", "  New file", "<cmd>ene <bar> startinsert<cr>"),
    dashboard.button("r", "  Recents", "<cmd>Telescope oldfiles<cr>"),
    dashboard.button("g", "  Grep", "<cmd>Telescope live_grep<cr>"),
    dashboard.button("l", "  Lazy", "<cmd>Lazy<cr>"),
    dashboard.button("q", "  Quit NVIM", "<cmd>qa<cr>"),
}

-- Стилизация: делаем акценты только на горячих клавишах
for _, button in ipairs(dashboard.section.buttons.val) do
    button.opts.hl = "Comment"          -- серый/второстепенный текст
    button.opts.hl_shortcut = "Special" -- акцентный цвет (розовый в TokyoNight, розовый/фиолетовый в Catppuccin)
end

-- Заголовок (котик) — оставляем серым, чтобы не перегружать
dashboard.section.header.val = ascii_art
dashboard.section.header.opts.hl = "Comment"

-- Убираем footer
dashboard.section.footer.val = {}
dashboard.section.footer.opts.hl = "Comment"

-- Макет: немного отступов, всё по центру
dashboard.opts.layout = {
    { type = "padding", val = 3 },
    dashboard.section.header,
    { type = "padding", val = 2 },
    dashboard.section.buttons,
    { type = "padding", val = 2 },
}

alpha.setup(dashboard.opts)
