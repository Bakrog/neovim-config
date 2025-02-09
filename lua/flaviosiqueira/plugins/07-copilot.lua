return {
    {
        "github/copilot.vim",
        enabled = false,
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            {
                "<C-a>",
                "<cmd>CodeCompanionActions<cr>",
                mode = {"n", "v"},
                noremap = true,
                silent = true,
            },
            {
                "<LocalLeader>a",
                "<cmd>CodeCompanionChat Toggle<cr>",
                mode = {"n", "v"},
                noremap = true,
                silent = true,
            },
            {
                "ga",
                "<cmd>CodeCompanionChat Add<cr>",
                mode = "v",
                noremap = true,
                silent = true,
            },
        },
        opts = {
            adapters = {
                gemini = function ()
                   return require("codecompanion.adapters").extend("gemini", {
                        schema = {
                            model = {
                                default = "gemini-2.0-flash",
                            },
                        },
                    })
                end
            },
            strategies = {
                -- Change the default chat adapter
                chat = {
                    adapter = "gemini",
                },
                inline = {
                    adapter = "gemini",
                },
            },
            opts = {
                -- Set debug logging
                --log_level = "DEBUG",
            },
        },
    },
}
