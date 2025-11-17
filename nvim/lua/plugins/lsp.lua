-- Mason для установки LSP серверов
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup()
mason_lspconfig.setup({
    ensure_installed = { "pyright", "gopls", "lua_ls" },
    automatic_installation = true,
})

-- Список серверов для включения
local servers = { "pyright", "gopls", "lua_ls" }

-- Включаем каждый сервер
for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

-- Автокоманды для LSP
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end

        local opts = { buffer = ev.buf, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float, opts)

        vim.notify("LSP attached: " .. client.name .. " for " .. vim.bo[ev.buf].filetype, vim.log.levels.INFO)
    end,
})

-- Автоформатирование при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("LspFormat", {}),
    callback = function(ev)
        local clients = vim.lsp.get_clients({ bufnr = ev.buf })
        if #clients > 0 then
            vim.lsp.buf.format({ async = false })
        end
    end,
})
