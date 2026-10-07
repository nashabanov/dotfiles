return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	priority = 1000,
	config = function()
		require("github-theme").setup({
			groups = {
				github_dark_dimmed = {
					UiAccent = { fg = "#539bf5" },
					SnacksPickerPrompt = { link = "UiAccent" },
					SnacksPickerMatch = { link = "UiAccent" },
					SnacksPickerTitle = { link = "FloatTitle" },
					NoiceCmdlinePopupBorder = { link = "FloatBorder" },
					NoiceCmdlineIcon = { link = "UiAccent" },
				},
			},
			options = {
				transparent = true,
				terminal_colors = true,
				styles = {
					comments = "italic",
					keywords = "NONE",
					functions = "NONE",
					variables = "NONE",
				},
			},
		})

		vim.cmd.colorscheme("github_dark_dimmed")
	end,
}
