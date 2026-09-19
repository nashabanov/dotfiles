-- nvim --headless -u NONE -i NONE -l nvim/tests/plugins.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local function load_plugin(name) return assert(loadfile(root .. "/lua/plugins/" .. name .. ".lua"))() end
local original_keymap_set = vim.keymap.set
local original_register = vim.treesitter.language.register
local mappings, registered, setup_config, cmdline_configs = {}, {}, nil, {}
local visible, next_item, previous_item, expanded, jumped = false, 0, 0, 0, 0

local cmp_setup = setmetatable({
    cmdline = function(mode, config) cmdline_configs[mode] = config end,
}, { __call = function(_, config) setup_config = config end })
local mapping = setmetatable({
    preset = { insert = function(config) return config end, cmdline = function() return {} end },
    scroll_docs = function(lines) return { scroll_docs = lines } end,
    complete = function() return "complete" end,
    abort = function() return "abort" end,
    confirm = function(options) return { confirm = options } end,
}, { __call = function(_, callback, modes) return { callback = callback, modes = modes } end })
package.loaded.cmp = {
    setup = cmp_setup,
    mapping = mapping,
    config = {
        window = { bordered = function(options) return options end },
        sources = function(sources) return sources end,
    },
    visible = function() return visible end,
    select_next_item = function() next_item = next_item + 1 end,
    select_prev_item = function() previous_item = previous_item + 1 end,
}
package.loaded.luasnip = {
    lsp_expand = function() end,
    expand_or_jumpable = function() return true end,
    expand_or_jump = function() expanded = expanded + 1 end,
    jumpable = function() return true end,
    jump = function() jumped = jumped + 1 end,
}

local ok, err = xpcall(function()
    load_plugin("cmp").config()
    assert(vim.deep_equal(setup_config.sources, {
        { name = "nvim_lsp", priority = 1000 }, { name = "luasnip", priority = 750 },
        { name = "path", priority = 600 }, { name = "buffer", priority = 500 },
    }))
    assert(cmdline_configs["/"].sources[1].name == "buffer" and cmdline_configs[":"].sources[1].name == "path")
    local tab = setup_config.mapping["<Tab>"].callback
    local fallback = function() error("Tab should not fall back") end
    visible = true
    tab(fallback)
    assert(next_item == 1)
    visible = false
    tab(fallback)
    assert(expanded == 1)
    setup_config.mapping["<S-Tab>"].callback(fallback)
    assert(previous_item == 0 and jumped == 1)

    vim.keymap.set = function(mode, key, action, options)
        mappings[key] = { mode = mode, action = action, options = options }
    end
    package.loaded.gitsigns = { nav_hunk = function(direction) registered.direction = direction end }
    local gitsigns = load_plugin("gitsigns")
    assert(gitsigns.event == "BufReadPre" and gitsigns.opts.signs.add.text == "▎")
    gitsigns.opts.on_attach(7)
    assert(mappings["]h"].options.buffer == 7 and mappings["]h"].options.desc == "Next hunk")
    mappings["]h"].action()
    assert(registered.direction == "next")

    vim.treesitter.language.register = function(language, filetype) registered[filetype] = language end
    local treesitter = load_plugin("treesitter")
    treesitter.config()
    assert(registered.jsonc == "json5")
    local modules = load_plugin("treesitter-modules")
    assert(modules.opts.highlight.enable and modules.opts.incremental_selection.keymaps.node_incremental == "<Enter>")
    assert(vim.tbl_contains(modules.opts.ensure_installed, "gowork"))
    assert(vim.tbl_contains(modules.opts.ensure_installed, "markdown_inline"))
end, debug.traceback)

vim.keymap.set = original_keymap_set
vim.treesitter.language.register = original_register
package.loaded.cmp, package.loaded.luasnip, package.loaded.gitsigns = nil, nil, nil
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
end
print("PASS: completion, gitsigns and treesitter plugin configuration")
vim.cmd("qa!")
