local function map(key, command, desc)
    vim.keymap.set("n", key, command, { silent = true, desc = desc })
end

-- Buffer navigation uses built-in commands.
map("<leader>1", "<cmd>bprevious<CR>", "Previous Buffer")
map("<leader>2", "<cmd>bnext<CR>", "Next Buffer")
map("<leader>bc", "<cmd>bdelete<CR>", "Close Current Buffer")
