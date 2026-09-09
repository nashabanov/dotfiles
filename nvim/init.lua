-- Set leaders before loading plugins and mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
require("core.ui")
require("core.plugins")
require("core.mappings")
