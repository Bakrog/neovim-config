-- lua/flaviosiqueira/plugins/14-ai.lua
-- AI and Copilot-like tools configuration

-- Define preferred AI models
local gemini_model = "gemini-2.5-pro-preview-06-05"
local claude_model = "claude-opus-4-20250514"
local ollama_model = "deepseek-r1:14b-qwen-distill-q8_0"

return {
    -- VectorCode for codebase context retrieval
    {
        "Davidyz/VectorCode",
        enabled = true,
        version = "*",
        build =
        "uv tool install --python-preference=system 'vectorcode[lsp] @ git+https://github.com/Davidyz/VectorCode'", -- Manual build if needed
        dependencies = { "nvim-lua/plenary.nvim" },
        -- Load lazily when VectorCode commands are used
        cmd = "VectorCode",
        opts = {
            -- Configuration options for VectorCode
            -- async_opts = { debounce = 500, exclude_this = false, notify = false },
            -- n_query = 1,
            -- async_backend = "lsp",
            -- exclude_this = false,
            -- notify = false,
            -- on_setup = { lsp = false },
        },
        config = function(_, opts)
            require("vectorcode").setup(opts)
            -- Optional: Start LSP server automatically if using LSP backend
            vim.lsp.config("vectorcode-server", {
                cmd = { "vectorcode-server" },
                root_markers = { ".vectorcode", ".git" },
            })
            vim.lsp.enable("vectorcode-server", true)
        end,
    },

    -- CodeCompanion for chat, actions, and inline suggestions
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim", -- For action palette / file selection
            {
                -- For diff view
                "echasnovski/mini.diff",
                version = false,
                lazy = false,
                config = function()
                    require("mini.diff").setup()
                end,
            },
            "Davidyz/VectorCode", -- For codebase context tool
            {
                "ravitemer/mcphub.nvim",
                build = "npm install -g mcp-hub@latest",
                config = function()
                    require("mcphub").setup()
                end,
            },
        },
        -- Load lazily via keys or commands
        cmd = { "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionInline" },
        keys = {
            { "<C-a>",          desc = "CodeCompanion Actions" },     -- Placeholder, mapped below
            { "<LocalLeader>a", desc = "Toggle CodeCompanion Chat" }, -- Placeholder
        },
        config = function()
            local codecompanion = require("codecompanion")
            local adapters = require("codecompanion.adapters")

            -- Setup VectorCode integration helpers
            -- local vectorcode_chat_tool, vectorcode_slash_command
            -- local vc_ok, vc_integrations = pcall(require, "vectorcode.integrations")
            -- if vc_ok then
            --     vectorcode_chat_tool = vc_integrations.codecompanion.chat.make_tool()
            --     vectorcode_slash_command = vc_integrations.codecompanion.chat.make_slash_command()
            -- else
            --     vectorcode_chat_tool = function()
            --         vim.notify("VectorCode integration not available", vim.log.levels.WARN)
            --     end
            --     vectorcode_slash_command = { description = "VectorCode not available" }
            -- end

            codecompanion.setup({
                -- Configure AI model adapters
                adapters = {
                    gemini = adapters.extend("gemini", {
                        schema = { model = { default = gemini_model } },
                    }),
                    anthropic = adapters.extend("anthropic", {
                        schema = { model = { default = claude_model } },
                    }),
                    ollama = adapters.extend("ollama", {
                        schema = { model = { default = ollama_model } },
                    }),
                    -- Add other adapters like Ollama, OpenAI if needed
                },
                -- Configure strategies (chat, inline, actions)
                strategies = {
                    chat = {
                        adapter = "gemini", -- Default chat adapter
                        -- Use default system prompt or customize
                        -- system_prompt = "You are CodeCompanion, an AI assistant in Neovim...",
                        slash_commands = {
                            -- File selection command using Telescope
                            ["file"] = {
                                callback = "strategies.chat.slash_commands.file",
                                description = "Select a file using Telescope",
                                opts = { provider = "telescope", contains_code = true },
                            },
                            ["buffer"] = {
                                callback = "strategies.chat.slash_commands.buffer",
                                description = "Select a buffer using Telescope",
                                opts = { provider = "telescope", contains_code = true },
                            },
                            ["symbols"] = {
                                callback = "strategies.chat.slash_commands.symbols",
                                description = "Select a symbols using Telescope",
                                opts = { provider = "telescope", contains_code = true },
                            },
                        },
                        tools = {
                            -- Add other tools if needed
                        },
                    },
                    inline = {
                        adapter = "gemini", -- Default adapter for inline suggestions
                        -- Customize inline prompts/templates if needed
                    },
                    actions = {
                        adapter = "gemini", -- Default adapter for actions palette
                        -- Customize action prompts/templates if needed
                    },
                },
                -- Configure display settings
                display = {
                    chat = {
                        provider = "default", -- Use the default chat window
                        window = {            -- Customize window appearance
                            border = "rounded",
                            -- width = 0.5, height = 0.5, row = 0.5, col = 0.5,
                        },
                    },
                    action_palette = {
                        prompt = "Action > ",
                        provider = "telescope", -- Use Telescope for action palette
                        opts = {
                            show_default_actions = true,
                            show_default_prompt_library = true,
                        },
                    },
                    diff = {
                        enabled = true,
                        provider = "mini_diff", -- Use mini.diff for diff view
                        layout = "vertical",
                        -- close_chat_at = 240, -- Adjust based on screen width
                        opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                    },
                },
                -- General options
                opts = {
                    log_level = "INFO", -- Set log level (DEBUG, INFO, WARN, ERROR)
                    -- notify_errors = true, -- Show notifications for errors
                },
                extensions = {
                    vectorcode = {
                        opts = {
                            add_tool = true,
                            add_slash_command = true,
                            tool_opts = {
                                max_num = { chunk = -1, document = -1 },
                                default_num = { chunk = 50, document = 10 },
                                -- include_stderr = false,
                                use_lsp = true,
                                no_duplicate = true,
                            },
                        },
                    },
                    mcphub = {
                        callback = "mcphub.extensions.codecompanion",
                        opts = {
                            show_result_in_chat = true, -- Show mcp tool results in chat
                            make_vars = true,           -- Convert resources to #variables
                            make_slash_commands = true, -- Add prompts as /slash commands
                        }
                    },
                },
            })

            -- Define Keybindings
            vim.keymap.set(
                { "n", "v" },
                "<C-a>",
                "<cmd>CodeCompanionActions<cr>",
                { noremap = true, silent = true, desc = "CodeCompanion Actions" }
            )
            vim.keymap.set(
                { "n", "v" },
                "<LocalLeader>a",
                "<cmd>CodeCompanionChat Toggle<cr>",
                { noremap = true, silent = true, desc = "Toggle CodeCompanion Chat" }
            )
            vim.keymap.set(
                "v",
                "ga",
                "<cmd>CodeCompanionChat Add<cr>",
                { noremap = true, silent = true, desc = "Add Visual Selection to Chat" }
            )

            -- Optional: CMP integration for inline suggestions (requires nvim-cmp)
            -- local cmp_ok, cmp = pcall(require, "cmp")
            -- if cmp_ok then
            --     cmp.setup.buffer({ sources = { { name = "codecompanion" } } })
            --     -- Add keybindings for CMP completion if needed
            -- end
        end,
    },
    -- Supermaven autocomplete
    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<Tab>",
                    clear_suggestion = "<C-Esc>",
                    accept_word = "<C-j>",
                },
            })
        end,
    }, -- End supermaven block
}      -- End return table
