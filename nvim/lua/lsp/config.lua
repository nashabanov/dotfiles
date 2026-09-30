-- Language servers discover project settings from their native configuration
-- files. Keep editor-wide policy out of diagnostics, build flags and formatting.
return {
    gopls = {
        settings = { gopls = {} },
        before_init = require("go-context").before_init,
    },
    ruff = {
        init_options = {
            settings = {
                configurationPreference = "filesystemFirst",
            },
        },
    },
}
