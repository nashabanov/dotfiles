-- nvim --headless -u NONE -i NONE -l nvim/tests/lsp.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
dofile(root .. "/tests/helpers/go_context.lua")
local registered, enabled, mappings = {}, {}, {}
local original_config, original_enable = vim.lsp.config, vim.lsp.enable
local original_map, original_system, original_start = vim.keymap.set, vim.system, vim.lsp.rpc.start
package.loaded.cmp_nvim_lsp = {
	default_capabilities = function()
		return { textDocument = { completion = { completionItem = { snippetSupport = true } } } }
	end,
}
local ok, err = xpcall(function()
	vim.lsp.config = function(name, config)
		assert(not registered[name], "Duplicate server: " .. name)
		registered[name] = config
	end
	vim.lsp.enable = function(name)
		enabled[name] = true
	end
	require("lsp")
	for _, name in ipairs(require("lsp.servers")) do
		assert(enabled[name])
		assert(registered[name].capabilities.textDocument.completion.completionItem.snippetSupport)
		assert(registered[name].on_attach == require("lsp.attach").on_attach)
	end
	for _, name in ipairs({
		"ruby_lsp",
		"herb_ls",
		"cssls",
		"gopls",
		"pyright",
		"ruff",
		"rust_analyzer",
		"vtsls",
		"tailwindcss",
	}) do
		assert(enabled[name], "Missing server: " .. name)
	end
	assert(not enabled.ts_ls and not enabled.rubocop and not enabled.solargraph)
	assert(registered.gopls.before_init == require("go-context").before_init)
	assert(registered.ruff.init_options.settings.configurationPreference == "filesystemFirst")
	assert(registered.ruby_lsp.init_options.formatter == "auto")
	assert(vim.deep_equal(registered.herb_ls.filetypes, { "eruby" }))
	assert(registered.herb_ls.init_options.formatter.enabled == false)
	assert(registered.herb_ls.init_options.linter.fixOnSave == false)

	-- Each workspace selects its own Ruby; don't run a gem's pinned Ruby shebang.
	for _, workspace in ipairs({ "/tmp/rails-a", "/tmp/rails-b" }) do
		vim.system = function(cmd, opts)
			assert(vim.deep_equal(cmd, { "mise", "where", "gem:ruby-lsp" }) and opts.cwd == workspace)
			return {
				wait = function()
					return { code = 0, stdout = "/tmp/mise/ruby-lsp\n" }
				end,
			}
		end
		vim.lsp.rpc.start = function(cmd, dispatchers, opts)
			assert(vim.deep_equal(vim.list_slice(cmd, 1, 5), { "mise", "exec", "--", "ruby", "-e" }))
			assert(cmd[6]:find('Gem::Specification.find_by_name("ruby-lsp")', 1, true))
			assert(opts.cwd == workspace and dispatchers.test)
			assert(cmd[7] == "/tmp/mise/ruby-lsp/libexec" and opts.env == nil)
			return "started"
		end
		assert(registered.ruby_lsp.cmd({ test = true }, { root_dir = workspace }) == "started")
	end
	vim.keymap.set = function(_, key, action, opts)
		assert(opts.buffer == 7)
		mappings[key] = action
	end
	registered.ruby_lsp.on_attach({ server_capabilities = {} }, 7)
	assert(mappings.gd == vim.lsp.buf.definition and mappings.K == vim.lsp.buf.hover)
	local picked
	package.loaded.snacks = { picker = {
		lsp_references = function()
			picked = true
		end,
	} }
	mappings.gr()
	assert(picked and mappings.gy and mappings["<leader>ca"] and mappings["<leader>rn"])
end, debug.traceback)
vim.lsp.config, vim.lsp.enable = original_config, original_enable
vim.keymap.set, vim.system, vim.lsp.rpc.start = original_map, original_system, original_start
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
print("PASS: LSP registration, completion capabilities, Rails workspace commands and existing mappings")
vim.cmd("qa!")
