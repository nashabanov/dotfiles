local M = {}

local go_build_tags = { "e2e", "e2e_pers_reserve", "e2e_with_approve", "functional", "smoke", "integration" }

M.gopls = {
    settings = {
        gopls = {
            buildFlags = { "-tags=" .. table.concat(go_build_tags, ",") },
            analyses = {
                unusedparams = true,
                unusedvariable = true,
            },
        },
    },
}

M.pyright = {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
}

M.ruff = {
    settings = {
        ruff = {
            lint = {
                select = { "ALL" },
                ignore = { "ANN" },
            },
            format = {
                lineLength = 88,
                quoteStyle = "double",
            },
        },
    },
}

M.rust_analyzer = {
    settings = {
        ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
            inlayHints = {
                typeHints = true,
                chainingHints = true,
            },
        },
    },
}

M.yamlls = {
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
            },
        },
    },
}

return M
