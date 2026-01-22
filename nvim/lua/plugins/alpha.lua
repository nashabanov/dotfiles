local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

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
dashboard.section.buttons.val = {
    dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
    dashboard.button("e", "  New file", "<cmd>ene <bar> startinsert<cr>"),

    dashboard.button("r", "  Recents", "<cmd>Telescope oldfiles<cr>"),
    dashboard.button("g", "  Grep", "<cmd>Telescope live_grep<cr>"),
    dashboard.button("l", "  Lazy", "<cmd>Lazy<cr>"),
    dashboard.button("q", "  Quit NVIM", "<cmd>qa<cr>"),
}

for _, button in ipairs(dashboard.section.buttons.val) do
    button.opts.hl = button.opts.hl or "Comment"
    button.opts.hl_shortcut = "Special"
end

dashboard.section.header.val = ascii_art
dashboard.section.header.opts.hl = "NonText"

dashboard.section.footer.val = {
    string.format(
        "  Neovim %s.%s  |  ⚡️ %d plugins",
        vim.version().major,
        vim.version().minor,
        require("lazy").stats().count
    )
}
dashboard.section.footer.opts.hl = "NonText"

dashboard.opts.layout = {
    { type = "padding", val = 4 },
    dashboard.section.header,
    { type = "padding", val = 3 },
    dashboard.section.buttons,
    { type = "padding", val = 2 },
    dashboard.section.footer,
}

alpha.setup(dashboard.opts)
