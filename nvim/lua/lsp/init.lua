local servers = require("lsp.servers")
local configs = require("lsp.config")
local attach = require("lsp.attach")
local format = require("lsp.format")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Configure completion capabilities before any server is enabled.
for _, server in ipairs(servers) do
	local config = vim.deepcopy(configs[server] or {})

	config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
	config.on_attach = attach.on_attach

	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end

format.setup()
