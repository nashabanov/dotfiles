local M = {}

function M.apply()
    local hl = vim.api.nvim_set_hl

    ------------------------------------------------------------------
    -- Comments & Inlay hints
    ------------------------------------------------------------------
    hl(0, "Comment", {
        fg = "#5C6773",
        italic = true,
    })

    hl(0, "LspInlayHint", {
        fg = "#606B7D",
        bg = "NONE",
        italic = true,
    })

    ------------------------------------------------------------------
    -- Parameters
    ------------------------------------------------------------------
    hl(0, "@parameter", {
        fg = "#99E1FD",
        italic = true,
    })

    hl(0, "@lsp.type.parameter", {
        fg = "#99E1FD",
        italic = true,
    })

    ------------------------------------------------------------------
    -- Variables / Properties
    ------------------------------------------------------------------
    hl(0, "@property", {
        fg = "#80D4FF",
    })

    hl(0, "@variable.member", {
        fg = "#80D4FF",
    })

    hl(0, "@variable.builtin", {
        fg = "#D4BFFF",
        italic = true,
    })

    ------------------------------------------------------------------
    -- Types
    ------------------------------------------------------------------
    hl(0, "@type.builtin", {
        fg = "#E6E6E6",
    })

    hl(0, "@type", {
        fg = "#73D0FF",
    })

    hl(0, "@lsp.type.type", {
        fg = "#73D0FF",
    })

    ------------------------------------------------------------------
    -- Classes
    ------------------------------------------------------------------
    hl(0, "@type.definition", {
        fg = "#8AD4FF",
        bold = true,
    })

    hl(0, "@lsp.type.class", {
        fg = "#8AD4FF",
        bold = true,
    })

    ------------------------------------------------------------------
    -- Functions
    ------------------------------------------------------------------
    hl(0, "@function", {
        fg = "#FFD57D",
    })

    hl(0, "@function.call", {
        fg = "#FFD57D",
    })

    hl(0, "@function.method", {
        fg = "#FFD57D",
    })

    hl(0, "@constructor", {
        fg = "#FFC44C",
    })

    ------------------------------------------------------------------
    -- Modules
    ------------------------------------------------------------------
    hl(0, "@module", {
        fg = "#99E1FD",
    })

    hl(0, "@namespace", {
        fg = "#99E1FD",
    })

    ------------------------------------------------------------------
    -- UI
    ------------------------------------------------------------------
    hl(0, "CursorLine", {
        bg = "#272D3D",
    })

    hl(0, "NormalFloat", {
        bg = "#272D3D",
    })

    hl(0, "FloatBorder", {
        fg = "#404859",
        bg = "#272D3D",
    })

    ------------------------------------------------------------------
    -- Diagnostics
    ------------------------------------------------------------------
    hl(0, "DiagnosticVirtualTextHint", {
        fg = "#5C6773",
        bg = "NONE",
    })

    hl(0, "DiagnosticVirtualTextInfo", {
        fg = "#73D0FF",
        bg = "NONE",
    })

    hl(0, "DiagnosticVirtualTextWarn", {
        fg = "#FFAE57",
        bg = "NONE",
    })

    hl(0, "DiagnosticVirtualTextError", {
        fg = "#F28779",
        bg = "NONE",
    })
end

return M
