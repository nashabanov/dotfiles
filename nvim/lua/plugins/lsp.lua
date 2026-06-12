-- Mason для установки LSP серверов
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local servers = {
    "pyright",
    "ruff",
    "gopls",
    "lua_ls",
    "vtsls",
    "eslint",
    "tailwindcss",
    "rust_analyzer",
}
local go_build_tags = { "e2e", "e2e_pers_reserve", "e2e_with_approve", "functional", "smoke", "integration" }


mason.setup()
mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_installation = true,
    handlers = {},
})


vim.lsp.config("gopls", {
    settings = {
        gopls = {
            buildFlags = { "-tags=" .. table.concat(go_build_tags, ",") },
            analyses = {
                unusedparams = true,
                unusedvariable = true,
            }
        }
    },
})

vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
})

vim.lsp.config("ruff", {
    settings = {
        ruff = {
            lint = {
                select = { "ALL" },
                ignore = { "ANN" },
            },
            format = {
                lineLength = 88,
                quoteStyle = "double",
            }
        }
    }
})

vim.lsp.config("rust_analizer", {
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
            },
            checkOnSave = {
                command = "clippy",
            },
            inlayHints = {
                bindingModeHints = true,
                chainingHints = true,
                closingBraceHints = true,
                typeHints = true,
            },
        },
    },
})

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

        -- vim.notify("LSP attached: " .. client.name .. " for " .. vim.bo[ev.buf].filetype, vim.log.levels.INFO)
    end,
})

-- Автоформатирование при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("LspFormat", {}),
    callback = function(ev)
        local clients = vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/formatting" })
        if #clients > 0 then
            vim.lsp.buf.format({
                bufnr = ev.buf,
                async = false,
                timeout_ms = 2000
            })
        end
    end,
})
