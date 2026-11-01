-- Language servers discover project settings from their native configuration
-- files. Keep editor-wide policy out of diagnostics, build flags and formatting.
return {
	ruby_lsp = {
		-- Resolve mise in the workspace, even when Neovim opened another project first.
		-- Run the gem with the project's Ruby instead of its installation shebang.
		cmd = function(dispatchers, config)
			local cwd = config.cmd_cwd or config.root_dir
			local tool = vim.system({ "mise", "where", "gem:ruby-lsp" }, { cwd = cwd, text = true }):wait()
			assert(tool.code == 0, tool.stderr)
			local gem_home = vim.trim(tool.stdout) .. "/libexec"
			-- Bypass RubyGems' eager dependency activation: the composed bundle must
			-- select native gems for this Ruby before Prism or other dependencies load.
			local launcher = 'ENV["GEM_PATH"] = (Gem.path + [ARGV.shift]).join(File::PATH_SEPARATOR); '
				.. 'Gem.clear_paths; load Gem::Specification.find_by_name("ruby-lsp").full_gem_path + "/exe/ruby-lsp"'
			return vim.lsp.rpc.start({ "mise", "exec", "--", "ruby", "-e", launcher, gem_home }, dispatchers, {
				cwd = cwd,
			})
		end,
		-- Rails add-on is included automatically in Ruby LSP's composed bundle.
		init_options = { formatter = "auto" },
	},
	herb_ls = {
		filetypes = { "eruby" },
		init_options = {
			formatter = { enabled = false },
			linter = { fixOnSave = false },
		},
	},
	gopls = {
		settings = { gopls = {} },
		before_init = require("go-context").before_init,
	},
	ruff = {
		init_options = {
			settings = {
				configurationPreference = "filesystemFirst",
			},
		},
	},
}
