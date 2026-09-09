return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    opts = {
        debug = {
            enabled = false,
            show_scores = false,
        },
    },
    lazy = false,
    keys = {
        { "<leader>ff", function() require("fff").find_files() end, desc = "Find Files" },
        { "<leader>fg", function() require("fff").live_grep() end, desc = "Search Text" },
        {
            "<leader>fz",
            function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end,
            desc = "Fuzzy Search Text",
        },
        {
            "<leader>fc",
            function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end,
            desc = "Search Current Word",
        },
    },
}
