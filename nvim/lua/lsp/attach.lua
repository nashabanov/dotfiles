local M = {}

function M.on_attach(client, bufnr)
    local opts = { buffer = bufnr, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled()
        )
    end)

    -- inlay hints
    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
end

return M
