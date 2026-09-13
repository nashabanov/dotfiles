-- Run with Neovim and Ruff installed (or set RUFF_BIN):
-- nvim --headless -u NONE -i NONE -l nvim/tests/project.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local ruff = vim.env.RUFF_BIN or vim.fn.exepath("ruff")
if ruff == "" then ruff = vim.fn.stdpath("data") .. "/mason/bin/ruff" end
assert(vim.fn.executable(ruff) == 1, "Install Ruff or set RUFF_BIN")
local configs = require("lsp.config")
local format = require("lsp.format")
local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
dir = assert(vim.uv.fs_realpath(dir))
local clients = {}
local function write(path, lines) vim.fn.writefile(lines, path) end
local function run()
    assert(configs.gopls.settings.gopls.buildFlags == nil)
    assert(configs.pyright == nil and configs.rust_analyzer == nil)
    assert(configs.yamlls == nil, "No global project-specific settings should remain")
    format.setup()
    local cases = {
        { name = "single", quote = "single", indent = 2, expected = "value = 'hello'" },
        { name = "double", quote = "double", indent = 4, expected = 'value = "hello"' },
    }
    for _, case in ipairs(cases) do
        local project = dir .. "/" .. case.name
        vim.fn.mkdir(project, "p")
        write(project .. "/pyproject.toml", {
            "[tool.ruff]", "line-length = 80", "[tool.ruff.format]",
            'quote-style = "' .. case.quote .. '"',
        })
        write(project .. "/.editorconfig", {
            "root = true", "[*]", "indent_style = space", "indent_size = " .. case.indent,
        })
        write(project .. "/main.py", { 'value="hello"' })
        vim.cmd.edit(project .. "/main.py")
        local buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].filetype = "python"
        require("editorconfig").config(buf)
        assert(vim.bo[buf].shiftwidth == case.indent, "Project indentation not applied")
        local config = vim.deepcopy(configs.ruff)
        -- Static fixtures do not need filesystem watchers.
        config.capabilities = vim.lsp.protocol.make_client_capabilities()
        config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
        config.name = "ruff"
        config.cmd = { ruff, "server" }
        config.root_dir = project
        local id = assert(vim.lsp.start(config, { bufnr = buf }))
        clients[#clients + 1] = id
        assert(vim.wait(10000, function()
            local client = vim.lsp.get_client_by_id(id)
            return client and client.initialized and vim.lsp.buf_is_attached(buf, id)
        end, 20), "Ruff failed to initialize")
        -- Compare real LSP formatting with the CLI in this project.
        local cli = vim.system({ ruff, "format", "--stdin-filename", project .. "/main.py", "-" }, {
            cwd = project, stdin = 'value="hello"\n', text = true,
        }):wait()
        assert(cli.code == 0, cli.stderr)
        vim.cmd("silent write")
        assert(vim.api.nvim_get_current_line() == case.expected, case.name .. ": wrong quote style: " .. vim.api.nvim_get_current_line())
        assert(table.concat(vim.fn.readfile(project .. "/main.py"), "\n") .. "\n" == cli.stdout,
            "LSP and project CLI disagree")
        case.buf = buf
    end
    assert(clients[1] ~= clients[2], "Projects must use separate Ruff workspaces")
    -- Revisit the first project while the second server remains active.
    vim.api.nvim_set_current_buf(cases[1].buf)
    vim.api.nvim_buf_set_lines(cases[1].buf, 0, -1, false, { 'value="hello"' })
    vim.cmd("silent write")
    assert(vim.api.nvim_get_current_line() == cases[1].expected, "Settings leaked across projects")
end
local ok, err = xpcall(run, debug.traceback)
for _, id in ipairs(clients) do
    local client = vim.lsp.get_client_by_id(id)
    if client then client:stop(true) end
end
vim.fn.delete(dir, "rf")
if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit 1") end
print("PASS: native project settings, two real Ruff workspaces, LSP/CLI agreement and EditorConfig")
vim.cmd("qa!")
