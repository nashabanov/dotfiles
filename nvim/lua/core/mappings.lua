vim.g.mapleader = " "

local keymap = vim.keymap.set

-- Helper для упрощения записи
local function map(key, cmd, desc)
    keymap("n", key, cmd, { desc = desc })
end

-- Neotree
map("<leader>e", ":Neotree right focus<CR>", "Neotree")
map("<leader>g", ":Neotree right git_status<CR>", "Neotree Git")

-- Bufferline
map("<leader>1", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("<leader>2", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("<leader>bc", "<cmd>BufferLinePickClose<cr>", "Close Buffer")

-- Telescope
local builtin = require("telescope.builtin")
map("<leader>ff", builtin.find_files, "Find Files")
map("<leader>fg", builtin.live_grep, "Live Grep")

map("gr", function()
    builtin.lsp_references({ include_declaration = false })
end, "Find References")

map("gd", function()
    builtin.lsp_definitions({ reuse_win = true })
end, "Go to Definition")

map("gi", function()
    builtin.lsp_implementations({ reuse_win = true })
end, "Go to Implementation")

map("gy", function()
    builtin.lsp_type_definitions({ reuse_win = true })
end, "Go to Type Definition")
