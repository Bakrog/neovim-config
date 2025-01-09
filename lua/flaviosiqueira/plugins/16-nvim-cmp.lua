return {
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
                { path = "nvim-dap-ui/librarydapui", words = { "vim%.dap" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    { -- optional cmp completion source for require statements and module annotations
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
        end,
    },
    { -- optional blink completion source for require statements and module annotations
        "saghen/blink.cmp",
        version = "v0.5.1", 
        opts = {
            sources = {
                -- add lazydev to your completion providers
                completion = {
                    enabled_providers = { "lsp", "path", "snippets", "buffer", "lazydev" },
                },
                providers = {
                    -- dont show LuaLS require statements when lazydev has items
                    lsp = { fallback_for = { "lazydev" } },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
                },
            },
            fuzzy = {
                force_version = "v0.5.1", -- force blink to use v0.5.1
            },
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            {
                "<leader>l",
                function ()
                    local conform = require("conform")
                    conform.format({
                        lsp_fallback = true,
                        async = false,
                        timeout_ms = 4000,
                    })
                end
            },
        },
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    kotlin = { "ktlint" },
                    python = { "ruff" },
                },
            })
        end,
    },
}

