local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

local servers = require("lsp.servers")
local configs = require("lsp.config")
local attach = require("lsp.attach")
local format = require("lsp.format")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

mason.setup()

-- Configure completion capabilities before any server is enabled.
for _, server in ipairs(servers) do
    local config = vim.deepcopy(configs[server] or {})

    config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
    config.on_attach = attach.on_attach

    vim.lsp.config(server, config)
end

mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_enable = false,
})

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

format.setup()
