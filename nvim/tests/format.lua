-- Run from the repository root:
-- nvim --headless -u NONE -i NONE -l nvim/tests/format.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local format = require("lsp.format")
local clients, calls, notifications = {}, {}, {}
local original_get_clients, original_notify = vim.lsp.get_clients, vim.notify
local temp_dir = vim.fn.tempname()
vim.fn.mkdir(temp_dir, "p")

vim.notify = function(message) notifications[#notifications + 1] = message end
vim.lsp.get_clients = function(filter)
    assert(filter.method == "textDocument/formatting")
    return vim.tbl_filter(function(client)
        return client.bufnr == filter.bufnr and client.can_format
    end, clients)
end

local function client(name, id, bufnr, behavior)
    return {
        name = name, id = id, bufnr = bufnr, can_format = true, offset_encoding = "utf-16",
        request_sync = function(self, method, params, timeout_ms, target)
            assert(method == "textDocument/formatting" and timeout_ms == 1000)
            assert(target == self.bufnr and params.textDocument.uri == vim.uri_from_bufnr(target))
            calls[#calls + 1] = self.id
            if behavior then return behavior(self, target) end
            return { result = {
                { range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 3 } },
                  newText = "formatted" },
            } }
        end,
    }
end

local function run()
    format.setup()
    format.setup()
    assert(#vim.api.nvim_get_autocmds({ group = "LspFormat" }) == 1)
    vim.cmd.edit(temp_dir .. "/first.txt")
    local first = vim.api.nvim_get_current_buf()
    local second = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(second, temp_dir .. "/second.txt")

    local function reset(filetype)
        vim.api.nvim_set_current_buf(first)
        vim.bo[first].filetype = filetype
        vim.bo[first].readonly = false
        vim.bo[first].modifiable = true
        vim.b[first].autoformat = nil
        vim.api.nvim_buf_set_lines(first, 0, -1, false, { "raw" })
        calls, notifications = {}, {}
    end
    local function save(expected)
        vim.cmd.write()
        assert(vim.fn.readfile(temp_dir .. "/first.txt")[1] == expected)
    end

    for filetype, name in pairs({ python = "ruff", lua = "lua_ls", go = "gopls", rust = "rust_analyzer" }) do
        reset(filetype)
        clients = { client("aaa_other", 2, first), client(name, 3, first), client(name, 1, first) }
        save("formatted")
        assert(vim.deep_equal(calls, { 1 }), "Preferred formatter must be the only request")
    end

    reset("javascript")
    clients = { client("z_server", 1, first), client("a_server", 2, first) }
    save("formatted")
    assert(vim.deep_equal(calls, { 2 }), "Fallback must be stable by name")
    reset("javascript")
    clients = { clients[2], clients[1] }
    save("formatted")
    assert(vim.deep_equal(calls, { 2 }), "Attachment order must not affect selection")

    reset("python")
    clients = { client("pyright", 1, first) }
    save("raw")
    assert(#calls == 0 and #notifications == 0, "Missing preferred formatter should be silent")
    reset("text")
    clients = { client("other_buffer", 1, second), client("no_formatting", 2, first) }
    clients[2].can_format = false
    save("raw")
    assert(#calls == 0 and #notifications == 0, "Unsupported/unattached clients must be skipped")

    reset("text")
    clients = { client("formatter", 1, first), client("formatter", 2, second) }
    vim.cmd.FormatOnSaveToggle()
    assert(vim.b[first].autoformat == false)
    save("raw")
    assert(#calls == 0)
    vim.api.nvim_set_current_buf(second)
    vim.api.nvim_buf_set_lines(second, 0, -1, false, { "raw" })
    format.format(second)
    assert(vim.deep_equal(calls, { 2 }), "Toggle must only affect the current buffer")
    vim.api.nvim_set_current_buf(first)
    vim.cmd.FormatOnSaveToggle()
    save("formatted")
    assert(vim.deep_equal(calls, { 2, 1 }))

    reset("text")
    vim.bo[first].readonly = true
    format.format(first)
    vim.bo[first].readonly = false
    vim.bo[first].modifiable = false
    format.format(first)
    vim.bo[first].modifiable = true
    local scratch = vim.api.nvim_create_buf(false, true)
    format.format(scratch)
    vim.api.nvim_buf_delete(scratch, { force = true })
    format.format(scratch)
    assert(#calls == 0, "Read-only, nonmodifiable, special and invalid buffers must be skipped")

    for _, behavior in ipairs({
        function() return { err = { message = "server error" } } end,
        function() error("formatter exception") end,
        function() return nil, "request failed" end,
    }) do
        reset("text")
        clients = { client("broken", 1, first, behavior) }
        save("raw")
        vim.wait(50, function() return #notifications > 0 end)
        assert(#notifications == 1, "Formatting failures must warn without aborting the write")
    end

    reset("text")
    clients = { client("slow", 1, first) }
    local cancelled = false
    -- Exercise Neovim's real synchronous request timeout and cancellation.
    clients[1].request_sync = require("vim.lsp.client").request_sync
    clients[1].request = function() return true, 42 end
    clients[1].cancel_request = function(_, id) assert(id == 42); cancelled = true end
    local started = vim.uv.hrtime()
    save("raw")
    local elapsed_ms = (vim.uv.hrtime() - started) / 1e6
    vim.wait(50, function() return #notifications > 0 end)
    assert(cancelled and elapsed_ms >= 900 and elapsed_ms < 2500, "Timeout must cancel the request in about one second")
    assert(#notifications == 1)

    reset("text")
    clients = { client("changed", 1, first, function(_, target)
        vim.api.nvim_buf_set_lines(target, 0, -1, false, { "newer content" })
        return { result = {} }
    end) }
    save("newer content")
    vim.wait(50, function() return #notifications > 0 end)
    assert(#notifications == 1, "Stale edits must be rejected")

    -- A non-current target must use its own URI and formatting options.
    reset("text")
    vim.bo[second].shiftwidth = 2
    vim.bo[second].expandtab = false
    clients = { client("formatter", 1, second) }
    clients[1].request_sync = function(_, _, params, _, target)
        assert(target == second and params.textDocument.uri == vim.uri_from_bufnr(second))
        assert(params.options.tabSize == 2 and params.options.insertSpaces == false)
        return { result = {} }
    end
    format.format(second)
    assert(vim.api.nvim_get_current_buf() == first)
end

local ok, err = xpcall(run, debug.traceback)
vim.lsp.get_clients, vim.notify = original_get_clients, original_notify
vim.fn.delete(temp_dir, "rf")
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
end
print("PASS: formatter selection, buffer isolation, writes, errors, real timeout cancellation and stale edits")
vim.cmd("qa!")
