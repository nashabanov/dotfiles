-- nvim --headless -u NONE -i NONE -l nvim/tests/go_tags.lua
vim.opt.rtp:prepend(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h"))
local tags = require("lsp.go_tags")
local dir = vim.fn.tempname()
vim.fn.mkdir(dir .. "/a", "p")
vim.fn.mkdir(dir .. "/b", "p")
local first, second = dir .. "/a", dir .. "/b"
local notices = {}
local clients = {
    { config = { root_dir = first }, settings = { gopls = { buildFlags = { "-mod=mod", "-tags", "old" } } } },
    { config = { root_dir = second }, settings = { gopls = { buildFlags = { "-tags=other" } } } },
}
for i, client in ipairs(clients) do
    client.notify = function(_, method, params)
        assert(method == "workspace/didChangeConfiguration")
        notices[i] = vim.deepcopy(params.settings)
    end
end
vim.lsp.get_clients = function(filter)
    return filter.bufnr and { clients[1] } or clients
end
vim.notify = function() end
local function run()
    assert(tags.read(first) == nil)
    tags.set(first, "e2e,smoke e2e")
    assert(vim.deep_equal(tags.read(first), { "e2e", "smoke" }))
    assert(vim.deep_equal(notices[1].gopls.buildFlags, { "-mod=mod", "-tags=e2e,smoke" }))
    assert(notices[2] == nil and tags.read(second) == nil, "Leaked into another project")
    assert(not pcall(tags.set, first, "e2e;touch"))
    assert(vim.deep_equal(tags.read(first), { "e2e", "smoke" }), "Invalid input changed file")
    local config = { root_dir = first, settings = { gopls = { buildFlags = { "-mod=mod" } } } }
    local shared = config.settings
    tags.before_init({}, config)
    assert(shared == config.settings and shared.gopls.buildFlags[2] == "-tags=e2e,smoke")
    local other = { root_dir = second, settings = { gopls = {} } }
    tags.before_init({}, other)
    assert(other.settings.gopls.buildFlags == nil)
    tags.setup()
    vim.cmd("GoBuildTags integration smoke")
    assert(vim.deep_equal(tags.read(first), { "integration", "smoke" }))
    vim.ui.input = function(opts, callback)
        assert(opts.default == "integration,smoke")
        callback(nil)
    end
    vim.cmd("GoBuildTags")
    assert(tags.read(first)[1] == "integration", "Cancel should not save")
    vim.cmd("GoBuildTags!")
    assert(#tags.read(first) == 0)
    assert(vim.deep_equal(notices[1].gopls.buildFlags, { "-mod=mod" }))
    assert(notices[2] == nil)
end
local ok, err = xpcall(run, debug.traceback)
vim.fn.delete(dir, "rf")
if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit 1") end
print("PASS: persistent tags, initialization, live notification, project isolation, validation and commands")
vim.cmd("qa!")
