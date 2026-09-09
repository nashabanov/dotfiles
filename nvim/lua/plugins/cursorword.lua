return {
    'nvim-mini/mini.cursorword',
    version = false,
    event = "CursorHold",
    config = function()
        require("mini.cursorword").setup()
    end,
}
