return {
	"dmtrKovalenko/fff.nvim",
	build = function()
		require("fff.download").download_or_build_binary()
	end,
	opts = {
		prompt = "  ",
		layout = {
			width = 0.8,
			height = 0.8,
			prompt_position = "top",
			preview_position = "right",
			preview_size = 0.5,
			border = "rounded",
		},
		-- Use the same theme groups as Snacks, even before its first picker opens.
		hl = {
			normal = "NormalFloat",
			border = "FloatBorder",
			title = "FloatTitle",
			prompt = "UiAccent",
			matched = "UiAccent",
			cursor = "CursorLine",
		},
		debug = {
			enabled = false,
			show_scores = false,
		},
	},
	lazy = false,
	keys = {
		{
			"<leader>ff",
			function()
				require("fff").find_files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fg",
			function()
				require("fff").live_grep()
			end,
			desc = "Search Text",
		},
		{
			"<leader>fz",
			function()
				require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
			end,
			desc = "Fuzzy Search Text",
		},
		{
			"<leader>fc",
			function()
				require("fff").live_grep({ query = vim.fn.expand("<cword>") })
			end,
			desc = "Search Current Word",
		},
	},
}
