local gemini_model = "gemini-2.5-pro-exp-03-25" --"gemini-2.0-flash-thinking-exp"
local claude_model = "claude-3-7-sonnet-20250219"
return {
    {
        "github/copilot.vim",
        enabled = false,
    },
    {
        "Davidyz/VectorCode",
        --version = "*",                                                        -- optional, depending on whether you're on nightly or release
        build = "uv tool install --python-preference=system 'vectorcode[lsp,legacy] @ git+https://github.com/Davidyz/VectorCode'", -- optional but recommended if you set `version = "*"`
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "VectorCode",                                              -- if you're lazy-loading VectorCode
        config = function()
            require("vectorcode").setup({
                async_opts = {
                    debounce = 500,
                    exclude_this = false,
                    notify = false,
                },
                n_query = 1,
                async_backend = "lsp",
                exclude_this = false,
                notify = false,
                on_setup = {
                    lsp = false,
                },
            });
        end
    },
    {
        "olimorris/codecompanion.nvim",
        enabled = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "echasnovski/mini.diff",
            "Davidyz/VectorCode",
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
        config = function()
            require("codecompanion").setup({
                adapters = {
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            schema = {
                                model = {
                                    default = gemini_model,
                                },
                            },
                        })
                    end,
                    anthropic = function()
                        return require("codecompanion.adapters").extend("anthropic", {
                            schema = {
                                model = {
                                    default = claude_model,
                                },
                            },
                        })
                    end
                },
                strategies = {
                    -- Change the default chat adapter
                    chat = {
                        adapter = "gemini",
                        slash_commands = {
                            codebase = require("vectorcode.integrations").codecompanion.chat.make_slash_command(),
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
                        tools = {
                            vectorcode = {
                                description = "Run VectorCode to retrieve the project context.",
                                callback = require("vectorcode.integrations").codecompanion.chat.make_tool(),
                            }
                        },
                    },
                    inline = {
                        adapter = "gemini",
                    },
                },
                display = {
                    action_palette = {
                        prompt = "Prompt ",                 -- Prompt used for interactive LLM calls
                        provider = "telescope",             -- default|telescope|mini_pick
                        opts = {
                            show_default_actions = true,    -- Show the default actions in the action palette?
                            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
                        },
                    },
                    diff = {
                        enabled = true,
                        close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
                        layout = "vertical", -- vertical|horizontal split for default provider
                        opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                        provider = "mini_diff", -- default|mini_diff
                    },
                },
                opts = {
                    -- Set debug logging
                    log_level = "DEBUG",
                },
            })
        end
    },
    {
        "milanglacier/minuet-ai.nvim",
        enabled = true,
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            -- optional, if you are using virtual-text frontend, nvim-cmp is not
            -- required.
            --{ "hrsh7th/nvim-cmp" },
            -- optional, if you are using virtual-text frontend, blink is not required.
            { "Saghen/blink.cmp" },
            { "Davidyz/VectorCode" },
        },
        config = function()
            local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
            require("minuet").setup {
                add_single_line_entry = true,
                n_completions = 1,
                cmp = {
                    enable_auto_complete = false,
                },
                blink = {
                    enable_auto_complete = true,
                },
                -- I recommend you start with a small context window firstly, and gradually
                -- increase it based on your local computing power.
                -- context_window = 1024,
                after_cursor_filter_length = 100,
                notify = "debug",
                provider = "gemini",
                provider_options = {
                    gemini = {
                        max_tokens = 512,
                        model = gemini_model,
                        stream = true,
                        api_key = "GEMINI_API_KEY",
                        system = {
                            template = '{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}',
                            repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
                        },
                        chat_input = {
                            template = '{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}',
                            repo_context = function(_, _, _)
                                local prompt_message = ''
                                local cache_result = vectorcode_cacher.query_from_cache(0, { notify = false })
                                for _, file in ipairs(cache_result) do
                                    prompt_message = prompt_message
                                        .. '<file_separator>'
                                        .. file.path
                                        .. '\n'
                                        .. file.document
                                end
                                if prompt_message ~= '' then
                                    prompt_message = '<repo_context>\n' .. prompt_message .. '\n</repo_context>'
                                end
                                return prompt_message
                            end,
                        },
                    },
                    claude = {
                        max_tokens = 512,
                        model = claude_model,
                        stream = true,
                        api_key = "ANTHROPIC_API_KEY",
                        system = {
                            template = '{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}',
                            repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
                        },
                        chat_input = {
                            template = '{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}',
                            repo_context = function(_, _, _)
                                local prompt_message = ''
                                local cache_result = vectorcode_cacher.query_from_cache(0, { notify = false })
                                for _, file in ipairs(cache_result) do
                                    prompt_message = prompt_message
                                        .. '<file_separator>'
                                        .. file.path
                                        .. '\n'
                                        .. file.document
                                end
                                if prompt_message ~= '' then
                                    prompt_message = '<repo_context>\n' .. prompt_message .. '\n</repo_context>'
                                end
                                return prompt_message
                            end,
                        },
                    },
                }
            }
        end,
    },
}
