local M = {}
local filename = ".nvim-go-tags"

local function normalize(root)
    return root and (vim.uv.fs_realpath(root) or vim.fs.normalize(root))
end

function M.parse(value)
    local tags, seen = {}, {}
    for tag in value:gmatch("[^,%s]+") do
        assert(tag:match("^[%w_.]+$"), "Invalid Go build tag: " .. tag)
        if not seen[tag] then tags[#tags + 1], seen[tag] = tag, true end
    end
    return tags
end

function M.read(root)
    if not root then return nil end
    local path = root .. "/" .. filename
    if vim.fn.filereadable(path) == 0 then return nil end
    return M.parse(table.concat(vim.fn.readfile(path), " "))
end

local function apply(settings, tags)
    settings.gopls = settings.gopls or {}
    local flags, skip = {}, false
    for _, flag in ipairs(settings.gopls.buildFlags or {}) do
        if skip then
            skip = false
        elseif flag == "-tags" then
            skip = true
        elseif not flag:match("^%-tags=") then
            flags[#flags + 1] = flag
        end
    end
    if #tags > 0 then flags[#flags + 1] = "-tags=" .. table.concat(tags, ",") end
    settings.gopls.buildFlags = flags
end

function M.before_init(_, config)
    local ok, tags = pcall(M.read, config.root_dir)
    if not ok then
        vim.schedule(function() vim.notify(tags, vim.log.levels.WARN) end)
    elseif tags then
        -- settings already exists and is shared with the newly created client.
        apply(config.settings, tags)
    end
end

function M.set(root, value)
    root = assert(normalize(root), "No Go workspace found")
    local tags = M.parse(value)
    assert(vim.fn.writefile({ table.concat(tags, ",") }, root .. "/" .. filename) == 0,
        "Could not save Go build tags")
    for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
        if normalize(client.config.root_dir) == root then
            apply(client.settings, tags)
            client:notify("workspace/didChangeConfiguration", { settings = client.settings })
        end
    end
    vim.notify("Go build tags: " .. (#tags > 0 and table.concat(tags, ", ") or "none") .. " (" .. root .. ")")
end

function M.setup()
    vim.api.nvim_create_user_command("GoBuildTags", function(opts)
        local roots = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "gopls" })) do
            local root = normalize(client.config.root_dir)
            if root then roots[root] = true end
        end
        local candidates = vim.tbl_keys(roots)
        if #candidates > 1 then
            vim.notify("Multiple Go workspaces attached; cannot choose where to save tags", vim.log.levels.WARN)
            return
        end
        local root = candidates[1] or vim.fs.root(0, { "go.work", "go.mod" })
        if not root then
            vim.notify("Open a file in a Go workspace first", vim.log.levels.WARN)
            return
        end
        local function save(value)
            if value == nil then return end
            local ok, err = pcall(M.set, root, value)
            if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
        end
        if opts.bang then
            save("")
        elseif opts.args ~= "" then
            save(opts.args)
        else
            local ok, tags = pcall(M.read, root)
            vim.ui.input({ prompt = "Go build tags (comma/space separated): ",
                default = ok and table.concat(tags or {}, ",") or "" }, save)
        end
    end, { nargs = "*", bang = true, desc = "Set persistent Go build tags for this workspace" })
end

return M
