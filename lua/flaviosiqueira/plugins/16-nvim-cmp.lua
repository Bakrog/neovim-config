return {
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        keys = {},
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library",       words = { "vim%.uv" } },
                { path = "nvim-dap-ui/librarydapui", words = { "vim%.dap" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    {                                        -- optional cmp completion source for require statements and module annotations
        "hrsh7th/nvim-cmp",
        keys = {},
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            opts.performance = opts.performance or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
            table.insert(opts.sources, { name = "minuet" })
            opts.performance.fetching_timeout = 2000
        end,
    },
    { -- optional blink completion source for require statements and module annotations
        "saghen/blink.cmp",
        version = '*',
        keys = {},
        opts = {
            sources = {
                -- add lazydev to your completion providers
                default = { "lsp", "path", "snippets", "buffer", "lazydev", "minuet" },
                providers = {
                    -- dont show LuaLS require statements when lazydev has items
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        fallbacks = { "lsp" },
                    },
                    minuet = {
                        name = "minuet",
                        module = "minuet.blink",
                        score_offset = 8, -- Gives minuet higher priority among suggestions
                    },
                },
                per_filetype = {
                    codecompanion = { "codecompanion" },
                },
            },
            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },
            fuzzy = { implementation = "prefer_rust" },
            completion = { trigger = { prefetch_on_insert = false } },
        },
        opts_extend = { "sources.default" },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            {
                "<leader>l",
                function()
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
                    python = { "ruff_fix", "ruff_format" },
                    -- Conform will run the first available formatter
                    javascript = { "prettierd", "prettier", stop_after_first = true },
                    typescript = { "prettierd", "prettier", stop_after_first = true },
                },
            })
        end,
    },
}
