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
map("gr", function()
    require("cinnamon").scroll(function()
        builtin.lsp_references({ include_declaration = false })
    end)
end, "Find References")

map("gd", function()
    require("cinnamon").scroll(function()
        vim.lsp.buf.definition()
    end)
end, "Go to Definition")

map("gi", vim.lsp.buf.incoming_calls, "Incoming Calls")
map("go", vim.lsp.buf.outgoing_calls, "Outgoing Calls")

map("K", vim.lsp.buf.hover, "Hover Documentation")

map("gy", function()
    builtin.lsp_type_definitions({ reuse_win = true })
end, "Go to Type Definition")

-- Cinnamon
local cinnamon = require("cinnamon")

map("n", function() cinnamon.scroll("n") end, "Next Search")
map("N", function() cinnamon.scroll("N") end, "Previous Search")

map("zz", function() cinnamon.scroll("zz") end, "Center Cursor")
map("zt", function() cinnamon.scroll("zt") end, "Cursor to Top")
map("zb", function() cinnamon.scroll("zb") end, "Cursor to Bottom")

map("gg", function() cinnamon.scroll("gg") end, "Go to Top")
map("G", function() cinnamon.scroll("G") end, "Go to Bottom")
