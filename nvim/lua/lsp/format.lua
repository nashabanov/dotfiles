local M = {}

local preferred = {
    python = "ruff",
    lua = "lua_ls",
    go = "gopls",
    rust = "rust_analyzer",
}

local function select_client(bufnr)
    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = "textDocument/formatting",
    })
    local name = preferred[vim.bo[bufnr].filetype]

    -- Keep the choice independent of the order in which servers attach.
    table.sort(clients, function(a, b)
        if a.name == b.name then return a.id < b.id end
        return a.name < b.name
    end)

    for _, client in ipairs(clients) do
        if not name or client.name == name then return client end
    end
end

function M.format(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then return end
    if vim.b[bufnr].autoformat == false then return end
    if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then return end

    local client = select_client(bufnr)
    if not client then return end

    -- Finish edits before writing. A failed request must not cancel the save.
    local ok, err = pcall(function()
        local params = vim.api.nvim_buf_call(bufnr, function()
            return vim.lsp.util.make_formatting_params()
        end)
        local tick = vim.api.nvim_buf_get_changedtick(bufnr)
        local response, request_error = client:request_sync("textDocument/formatting", params, 1000, bufnr)
        if not response then error(request_error or "Formatting request failed", 0) end
        if response.err then error(response.err.message or vim.inspect(response.err), 0) end
        if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then
            error("Buffer changed while formatting; edits skipped", 0)
        end
        if response.result then
            vim.lsp.util.apply_text_edits(response.result, bufnr, client.offset_encoding)
        end
    end)
    if not ok then
        vim.schedule(function()
            vim.notify("[Format][" .. client.name .. "] " .. tostring(err), vim.log.levels.WARN)
        end)
    end
end

function M.setup()
    vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.b[bufnr].autoformat = vim.b[bufnr].autoformat == false
        local state = vim.b[bufnr].autoformat and "enabled" or "disabled"
        vim.notify("Format on save " .. state .. " for this buffer")
    end, { desc = "Toggle format on save for the current buffer" })

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
        callback = function(ev) M.format(ev.buf) end,
    })
end

return M
