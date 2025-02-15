return {
    {
        "github/copilot.vim",
        enabled = false,
    },
    {
        "olimorris/codecompanion.nvim",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "echasnovski/mini.diff",
        },
        keys = {
            {
                "<C-a>",
                "<cmd>CodeCompanionActions<cr>",
                mode = { "n", "v" },
                noremap = true,
                silent = true,
            },
            {
                "<LocalLeader>a",
                "<cmd>CodeCompanionChat Toggle<cr>",
                mode = { "n", "v" },
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
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        schema = {
                            model = {
                                default = "gemini-2.0-pro-exp-02-05",
                            },
                        },
                    })
                end,
                anthropic = function ()
                    return require("codecompanion.adapters").extend("anthropic", {
                        schema = {
                            model = {
                                default = "claude-3-5-sonnet-20241022",
                            },
                        },
                    })
                end
            },
            strategies = {
                -- Change the default chat adapter
                chat = {
                    adapter = "anthropic",
                    slash_commands = {
                        ["file"] = {
                            -- Location to the slash command in CodeCompanion
                            callback = "strategies.chat.slash_commands.file",
                            description = "Select a file using Telescope",
                            opts = {
                                provider = "telescope", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
                                contains_code = true,
                            },
                        },
                    },
                },
                inline = {
                    adapter = "anthropic",
                },
            },
            display = {
                action_palette = {
                    prompt = "Prompt ",     -- Prompt used for interactive LLM calls
                    provider = "telescope",   -- default|telescope|mini_pick
                    opts = {
                        show_default_actions = true, -- Show the default actions in the action palette?
                        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
                    },
                },
                diff = {
                    enabled = true,
                    close_chat_at = 240,    -- Close an open chat buffer if the total columns of your display are less than...
                    layout = "vertical",    -- vertical|horizontal split for default provider
                    opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                    provider = "mini_diff", -- default|mini_diff
                },
            },
            opts = {
                -- Set debug logging
                --log_level = "DEBUG",
            },
        },
    },
}
