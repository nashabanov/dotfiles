return {
    "declancm/cinnamon.nvim",
    version = "*",
    keys = {
        { "<C-u>", function() require("cinnamon").scroll("<C-u>") end, desc = "Scroll Up" },
        { "<C-d>", function() require("cinnamon").scroll("<C-d>") end, desc = "Scroll Down" },
        { "<C-b>", function() require("cinnamon").scroll("<C-b>") end, desc = "Page Up" },
        { "<C-f>", function() require("cinnamon").scroll("<C-f>") end, desc = "Page Down" },
        { "<C-y>", function() require("cinnamon").scroll("<C-y>") end, desc = "Scroll Window Up" },
        { "<C-e>", function() require("cinnamon").scroll("<C-e>") end, desc = "Scroll Window Down" },
        { "n", function() require("cinnamon").scroll("n") end, desc = "Next Search" },
        { "N", function() require("cinnamon").scroll("N") end, desc = "Previous Search" },
        { "zz", function() require("cinnamon").scroll("zz") end, desc = "Center Cursor" },
        { "zt", function() require("cinnamon").scroll("zt") end, desc = "Cursor to Top" },
        { "zb", function() require("cinnamon").scroll("zb") end, desc = "Cursor to Bottom" },
        { "gg", function() require("cinnamon").scroll("gg") end, desc = "Go to Top" },
        { "G", function() require("cinnamon").scroll("G") end, desc = "Go to Bottom" },
    },
    config = function()
        require("cinnamon").setup({
            delay = 10,
            mode = "cursor",
        })
    end,
}
