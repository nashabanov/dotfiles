-- Language servers discover project settings from their native configuration
-- files. Keep editor-wide policy out of diagnostics, build flags and formatting.
-- Go build tags are supplied per workspace by :GoBuildTags (.nvim-go-tags).
return {
    gopls = {
        settings = { gopls = {} },
        before_init = require("lsp.go_tags").before_init,
    },
    ruff = {
        init_options = {
            settings = {
                configurationPreference = "filesystemFirst",
            },
        },
    },
}
