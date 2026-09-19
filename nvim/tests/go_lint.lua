-- nvim --headless -u NONE -i NONE -l nvim/tests/go_lint.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local go_lint = require("lsp.go_lint")
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
vim.fn.writefile({ "module example.com/test" }, temp .. "/go.mod")
vim.fn.writefile({ "integration, smoke" }, temp .. "/.nvim-go-tags")
vim.cmd.edit(temp .. "/main.go")
vim.bo.filetype = "go"

local original_get_clients, original_executable = vim.lsp.get_clients, vim.fn.executable
local calls = {}
local normalized_temp = vim.uv.fs_realpath(temp) or temp
vim.lsp.get_clients = function(filter)
    assert(filter.bufnr == 0 or filter.bufnr == vim.api.nvim_get_current_buf())
    return { { config = { root_dir = temp } } }
end
vim.fn.executable = function(command)
    if command == "golangci-lint" then return 1 end
    return original_executable(command)
end
package.loaded.lint = {
    try_lint = function(name, opts)
        calls[#calls + 1] = { name = name, cwd = opts.cwd, linter = opts.wrap_linter({ args = { "run", function() return "." end } }) }
    end,
}

local ok, err = xpcall(function()
    assert(go_lint.workspace_root(0) == normalized_temp)
    go_lint.run()
    assert(#calls == 1 and calls[1].name == "golangcilint" and calls[1].cwd == normalized_temp)
    assert(vim.deep_equal(calls[1].linter.args, { "run", "--build-tags=integration,smoke", calls[1].linter.args[3] }))
    assert(type(calls[1].linter.args[3]) == "function")
    vim.fn.writefile({ "" }, temp .. "/.nvim-go-tags")
    local linter = { args = { "run" } }
    assert(go_lint.with_build_tags(linter, temp) == linter and vim.deep_equal(linter.args, { "run" }))
end, debug.traceback)

vim.lsp.get_clients, vim.fn.executable = original_get_clients, original_executable
package.loaded.lint = nil
vim.fn.delete(temp, "rf")
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
end
print("PASS: golangci-lint uses the Go workspace and project tags")
vim.cmd("qa!")
