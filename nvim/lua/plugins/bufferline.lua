local bufferline = require("bufferline")

vim.opt.termguicolors = true

bufferline.setup({
    options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        offsets = {
            {
                filetype = "neo-tree",
                text = "Explorer",
                highlight = "Directory",
                text_align = "left",
            },
        },
        diagnostics_indicator = function(count, level)
            local icon = level:match("error") and "" or ""
            if count > 0 then return " " .. icon .. count end
            return ""
        end,
    }
})
