-- Базовые настройки
vim.opt.number = true         -- Нумерация строк
vim.opt.relativenumber = true -- Относительная нумерация
vim.opt.tabstop = 4           -- Размер табуляции
vim.opt.shiftwidth = 4        -- Размер отступа
vim.opt.expandtab = true      -- Табы как пробелы
vim.opt.ignorecase = true     -- Игнор регистра в поиске
vim.opt.smartcase = true      -- Умный поиск с учетом регистра
vim.opt.smartindent = true    -- Умные отступы
vim.opt.cmdheight = 0
vim.opt.breakindent = true

-- Импорты
require("core.plugins")
require("core.mappings")

-- Общая прозрачность для всего интерфейса
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.fillchars = {
    vert = " ",
    eob = " ",
    fold = " ",
}

vim.api.nvim_create_autocmd("WinNew", {
    callback = function()
        local win = vim.api.nvim_get_current_win()
        local config = vim.api.nvim_win_get_config(win)

        if config.relative ~= "" then
            vim.wo[win].winblend = 25
        end
    end,
})
