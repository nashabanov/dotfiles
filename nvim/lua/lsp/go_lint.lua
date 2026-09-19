local M = {}

local function normalize(root)
    return root and (vim.uv.fs_realpath(root) or vim.fs.normalize(root))
end

function M.workspace_root(bufnr)
    local roots = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })) do
        local root = normalize(client.config.root_dir)
        if root then roots[root] = true end
    end
    local candidates = vim.tbl_keys(roots)
    if #candidates == 1 then return candidates[1] end
    return vim.fs.root(bufnr, { "go.work", "go.mod" })
end

function M.with_build_tags(linter, root)
    local ok, tags = pcall(require("lsp.go_tags").read, root)
    if not ok or not tags or #tags == 0 or not linter.args then return linter end

    local args = vim.deepcopy(linter.args)
    local tag_arg = "--build-tags=" .. table.concat(tags, ",")
    for index, arg in ipairs(args) do
        if type(arg) == "function" then
            table.insert(args, index, tag_arg)
            linter.args = args
            return linter
        end
    end
    args[#args + 1] = tag_arg
    linter.args = args
    return linter
end

function M.run(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= "go" or vim.fn.executable("golangci-lint") ~= 1 then return end
    local root = M.workspace_root(bufnr)
    if not root then return end

    vim.api.nvim_buf_call(bufnr, function()
        require("lint").try_lint("golangcilint", {
            cwd = root,
            ignore_errors = true,
            wrap_linter = function(linter) return M.with_build_tags(linter, root) end,
        })
    end)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("GoLint", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.go",
        callback = function(event) M.run(event.buf) end,
        desc = "Run golangci-lint for the Go workspace",
    })
    vim.api.nvim_create_user_command("GoLint", function()
        if vim.fn.executable("golangci-lint") ~= 1 then
            vim.notify("golangci-lint is not available on PATH", vim.log.levels.WARN)
            return
        end
        M.run()
    end, { desc = "Run golangci-lint for the current Go file" })
end

return M
