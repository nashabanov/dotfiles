return {
    "declancm/cinnamon.nvim",
    version = "*",
    keys = {
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
