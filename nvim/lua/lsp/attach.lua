local M = {}

function M.on_attach(client, bufnr)
    local function map(key, action, desc)
        vim.keymap.set("n", key, action, { buffer = bufnr, silent = true, desc = desc })
    end

    map("gd", function()
        require("cinnamon").scroll(function()
            vim.lsp.buf.definition()
        end)
    end, "Go to Definition")
    map("gr", function()
        require("cinnamon").scroll(function()
            require("telescope.builtin").lsp_references({ include_declaration = false })
        end)
    end, "Find References")
    map("gy", function()
        require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
    end, "Go to Type Definition")
    map("gi", vim.lsp.buf.incoming_calls, "Incoming Calls")
    map("go", vim.lsp.buf.outgoing_calls, "Outgoing Calls")
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
    map("<leader>D", vim.diagnostic.open_float, "Line Diagnostics")
    map("<leader>ih", function()
        local filter = { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
    end, "Toggle Inlay Hints")

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
end

return M
