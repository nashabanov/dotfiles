local M = {}

local priority = {
    python = { "ruff" },
    lua = { "lua_ls" },
    go = { "gopls" },
    rust = { "rust_analyzer" },
}

function M.format(bufnr)
    local ft = vim.bo[bufnr].filetype
    local preferred = priority[ft]

    vim.lsp.buf.format({
        bufnr = bufnr,
        async = false,
        timeout_ms = 2000,
        filter = function(client)
            if not preferred then return true end
            return vim.tbl_contains(preferred, client.name)
        end,
    })
end

return M
