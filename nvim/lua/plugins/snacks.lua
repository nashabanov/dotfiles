return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<leader>e",
			function()
				local snacks = require("snacks")
				local explorer = snacks.picker.get({ source = "explorer" })[1]
				if explorer then
					explorer:focus()
				else
					snacks.explorer()
				end
			end,
			desc = "File Explorer",
		},
		{
			"<leader>g",
			function()
				require("snacks").picker.git_status()
			end,
			desc = "Git Status",
		},
	},
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				header = table.concat({
					"  ┌───────────────────────┐",
					"  │        /\\_/\\          │",
					"  │       ( •ᴗ• )         │",
					"  │        /   \\          │",
					"  │                       │",
					'  │>_ git commit -m "meow"│',
					"  │                       │",
					"  └───────────────────────┘",
				}, "\n"),
				keys = {
					{
						key = "f",
						icon = " ",
						desc = "Find file",
						action = function()
							require("fff").find_files()
						end,
					},
					{ key = "e", icon = " ", desc = "New file", action = ":ene | startinsert" },
					{
						key = "r",
						icon = " ",
						desc = "Recents",
						action = function()
							require("snacks").picker.recent()
						end,
					},
					{
						key = "g",
						icon = " ",
						desc = "Search text",
						action = function()
							require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
						end,
					},
					{ key = "l", icon = " ", desc = "Lazy", action = ":Lazy" },
					{ key = "q", icon = " ", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header", padding = 3 },
				{ section = "keys", gap = 1, padding = 2 },
				function()
					return {
						footer = string.format(
							"  Neovim %s.%s  |   %d plugins",
							vim.version().major,
							vim.version().minor,
							require("lazy").stats().count
						),
					}
				end,
			},
			formats = {
				header = { "%s", align = "center", hl = "NonText" },
				footer = { "%s", align = "center", hl = "NonText" },
				desc = { "%s", hl = "Comment" },
				key = { "%s", hl = "UiAccent" },
			},
		},
		explorer = { enabled = true, trash = false },
		notifier = { enabled = true, timeout = 2000, style = "compact" },
		styles = { notification = { border = "rounded", wo = { winblend = 25 } } },
		indent = {
			enabled = true,
			indent = { char = "│", hl = "Whitespace" },
			scope = { enabled = false },
			animate = { enabled = false },
			filter = function(buf)
				return vim.bo[buf].buftype == ""
					and not vim.tbl_contains({ "", "help", "man", "gitcommit", "checkhealth", "lspinfo" }, vim.bo[buf].filetype)
			end,
		},
		scroll = {
			enabled = true,
			animate = { duration = { step = 10, total = 200 }, easing = "linear" },
		},
		picker = {
			enabled = true,
			-- Keep code actions and other vim.ui.select users unchanged.
			ui_select = false,
			prompt = "  ",
			layout = { preset = "default" },
			layouts = {
				default = {
					layout = {
						box = "horizontal",
						backdrop = false,
						width = 0.8,
						height = 0.8,
						{
							box = "vertical",
							border = "rounded",
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
						{ win = "preview", title = "{preview}", border = "rounded", width = 0.5 },
					},
				},
			},
			win = {
				input = { wo = { winblend = 25 } },
				list = { wo = { winblend = 25 } },
				preview = { wo = { winblend = 25 } },
			},
			icons = {
				files = { dir = "", dir_open = "", file = "" },
				git = {
					added = "+",
					modified = "~",
					deleted = "-",
					renamed = "→",
					untracked = "?",
					ignored = "◌",
					staged = "✓",
					unmerged = "!",
				},
			},
			sources = {
				explorer = {
					format = function(item, picker)
						local snacks = require("snacks")
						item.filename_hl = item.dir and "SnacksPickerDirectory" or "SnacksPickerFile"
						local ret = snacks.picker.format.file(item, picker)
						-- Snacks 2.30 passes a full path to devicons; named icons need the basename.
						if not item.dir then
							local name = vim.fs.basename(item.file)
							local icon, hl = require("nvim-web-devicons").get_icon(name, nil, { default = true })
							for i, part in ipairs(ret) do
								if (part.field == "file" or part.resolve) and ret[i - 1] and ret[i - 1].virtual then
									ret[i - 1][1] = snacks.picker.util.align(icon, picker.opts.formatters.file.icon_width)
									ret[i - 1][2] = hl
									break
								end
							end
						end
						return ret
					end,
					hidden = true,
					ignored = false,
					exclude = { ".git", "node_modules", "__pycache__", ".ruff_cache", ".DS_Store" },
					layout = { preset = "sidebar", preview = false, layout = { position = "right", width = 32, min_width = 32 } },
					win = {
						list = {
							keys = {
								["<Space>"] = { "confirm", nowait = false },
								["S"] = "edit_split",
								["s"] = "edit_vsplit",
								["t"] = "edit_tab",
								["w"] = { "pick_win", "jump" },
								["C"] = "explorer_close",
								["z"] = "explorer_close_all",
								["R"] = "explorer_update",
								["A"] = "explorer_add",
								["?"] = "toggle_help_list",
							},
						},
					},
				},
				files = { layout = { preset = "default" } },
				grep = { layout = { preset = "default" } },
				lsp_references = { include_declaration = false, include_current = true, auto_confirm = false },
			},
		},
	},
}
