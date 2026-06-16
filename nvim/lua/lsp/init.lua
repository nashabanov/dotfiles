local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

local servers = require("lsp.servers")
local configs = require("lsp.config")
local attach = require("lsp.attach")
local format = require("lsp.format")

mason.setup()

mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_installation = true,
})

-- diagnostics (глобально)
vim.diagnostic.config({
    virtual_text = true,
    float = { border = "rounded" },
    severity_sort = true,
})

-- setup servers
for _, server in ipairs(servers) do
    local config = configs[server] or {}

    config.on_attach = attach.on_attach

    vim.lsp.config(server, config)
    vim.lsp.enable(server)
end

-- format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("LspFormat", {}),
    callback = function(ev)
        format.format(ev.buf)
    end,
})
