return {
    "rcarriga/nvim-notify",
    opts = {
        stages = "fade",
        timeout = 2000,
        render = "compact",
        background_colour = "#000000",
    },
    init = function()
        vim.notify = require("notify")
    end,
}
