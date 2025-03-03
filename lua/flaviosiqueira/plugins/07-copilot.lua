local gemini_prompt = [[
You are the backend of an AI-powered code completion engine. Your task is to
provide code suggestions based on the user's input. The user's code will be
enclosed in markers:

- `<contextAfterCursor>`: Code context after the cursor
- `<cursorPosition>`: Current cursor location
- `<contextBeforeCursor>`: Code context before the cursor
]]

local gemini_few_shots = {}

gemini_few_shots[1] = {
    role = 'user',
    content = [[
# language: python
<contextBeforeCursor>
def fibonacci(n):
    <cursorPosition>
<contextAfterCursor>

fib(5)]],
}

local gemini_chat_input_template =
'{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}'


return {
    {
        "github/copilot.vim",
        enabled = false,
    },
    {
        "olimorris/codecompanion.nvim",
        enabled = true,
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
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        schema = {
                            model = {
                                default = "claude-3-7-sonnet-20250219",
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
                    prompt = "Prompt ",                     -- Prompt used for interactive LLM calls
                    provider = "telescope",                 -- default|telescope|mini_pick
                    opts = {
                        show_default_actions = true,        -- Show the default actions in the action palette?
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
    {
        "milanglacier/minuet-ai.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            -- optional, if you are using virtual-text frontend, nvim-cmp is not
            -- required.
            { "hrsh7th/nvim-cmp" },
            -- optional, if you are using virtual-text frontend, blink is not required.
            { "Saghen/blink.cmp" },
        },
        config = function()
            gemini_few_shots[2] = require('minuet.config').default_few_shots[2]

            require("minuet").setup {
                -- Your configuration options here
                provider = "claude",
                provider_options = {
                    claude = {
                        max_tokens = 512,
                        model = "claude-3-7-sonnet-20250219",
                        system = {
                            prompt = gemini_prompt,
                        },
                        few_shots = gemini_few_shots,
                        chat_input = {
                            template = gemini_chat_input_template,
                        },
                        stream = true,
                        api_key = "ANTHROPIC_API_KEY",
                        optional = {
                            generationConfig = {
                                maxOutputTokens = 256,
                                topP = 0.9,
                            },
                            safetySettings = {
                                {
                                    category = 'HARM_CATEGORY_DANGEROUS_CONTENT',
                                    threshold = 'BLOCK_NONE',
                                },
                                {
                                    category = 'HARM_CATEGORY_HATE_SPEECH',
                                    threshold = 'BLOCK_NONE',
                                },
                                {
                                    category = 'HARM_CATEGORY_HARASSMENT',
                                    threshold = 'BLOCK_NONE',
                                },
                                {
                                    category = 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                                    threshold = 'BLOCK_NONE',
                                },
                            },
                        },
                    },
                }
            }
        end,
    },
}
