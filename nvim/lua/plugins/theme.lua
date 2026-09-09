return {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    priority = 1000,
    config = function()
        require("github-theme").setup({
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
