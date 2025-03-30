-- lua/flaviosiqueira/plugins/14-ai.lua
-- AI and Copilot-like tools configuration

-- Define preferred AI models
local gemini_model = "gemini-1.5-flash-latest" -- Or "gemini-1.5-pro-latest"
local claude_model = "claude-3-haiku-20240307" -- Or Sonnet/Opus models

return {
    -- VectorCode for codebase context retrieval
    {
        "Davidyz/VectorCode",
        -- build = "uv tool install --python-preference=system 'vectorcode[lsp,legacy] @ git+https://github.com/Davidyz/VectorCode'", -- Manual build if needed
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
             local lspconfig = require("lspconfig")
             lspconfig.vectorcode_server.setup({
                 cmd = {"vectorcode-server"},
                 root_dir = function()
                    return lspconfig.util.root_pattern(".vectorcode", ".git")(vim.api.nvim_buf_get_name(0))
                 end,
             })
        end
    },

    -- CodeCompanion for chat, actions, and inline suggestions
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim", -- For action palette / file selection
            "echasnovski/mini.diff",         -- For diff view
            "Davidyz/VectorCode",            -- For codebase context tool
            "hrsh7th/nvim-cmp",              -- Optional: for cmp integration if needed
        },
        -- Load lazily via keys or commands
        cmd = { "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionInline" },
        keys = {
            { "<C-a>", desc = "CodeCompanion Actions" }, -- Placeholder, mapped below
            { "<LocalLeader>a", desc = "Toggle CodeCompanion Chat" }, -- Placeholder
        },
        config = function()
            local codecompanion = require("codecompanion")
            local adapters = require("codecompanion.adapters")
            local strategies = require("codecompanion.strategies")

            -- Setup VectorCode integration helpers
            local vectorcode_chat_tool, vectorcode_slash_command
            local vc_ok, vc_integrations = pcall(require, "vectorcode.integrations")
            if vc_ok then
                vectorcode_chat_tool = vc_integrations.codecompanion.chat.make_tool()
                vectorcode_slash_command = vc_integrations.codecompanion.chat.make_slash_command()
            else
                vectorcode_chat_tool = function() vim.notify("VectorCode integration not available", vim.log.levels.WARN) end
                vectorcode_slash_command = { description = "VectorCode not available" }
            end

            codecompanion.setup({
                -- Configure AI model adapters
                adapters = {
                    gemini = adapters.extend("gemini", {
                        schema = { model = { default = gemini_model } }
                    }),
                    anthropic = adapters.extend("anthropic", {
                        schema = { model = { default = claude_model } }
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
                            -- Default slash commands (e.g., /explain, /tests)
                            strategies.chat.slash_commands.defaults(),
                            -- VectorCode integration for codebase context
                            ["codebase"] = vectorcode_slash_command,
                            -- File selection command using Telescope
                            ["file"] = {
                                callback = "strategies.chat.slash_commands.file",
                                description = "Select a file using Telescope",
                                opts = { provider = "telescope", contains_code = true },
                            },
                        },
                        tools = {
                            -- VectorCode tool
                            vectorcode = {
                                description = "Retrieve project context using VectorCode.",
                                callback = vectorcode_chat_tool,
                            }
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
                         window = { -- Customize window appearance
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
                        provider = "mini.diff", -- Use mini.diff for diff view
                        layout = "vertical",
                        -- close_chat_at = 240, -- Adjust based on screen width
                        opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap" },
                    },
                },
                -- General options
                opts = {
                    log_level = "INFO", -- Set log level (DEBUG, INFO, WARN, ERROR)
                    -- notify_errors = true, -- Show notifications for errors
                },
            })

            -- Define Keybindings
            vim.keymap.set({"n", "v"}, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = "CodeCompanion Actions" })
            vim.keymap.set({"n", "v"}, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true, desc = "Toggle CodeCompanion Chat" })
            vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true, desc = "Add Visual Selection to Chat" })

            -- Optional: CMP integration for inline suggestions (requires nvim-cmp)
             -- local cmp_ok, cmp = pcall(require, "cmp")
             -- if cmp_ok then
             --     cmp.setup.buffer({ sources = { { name = "codecompanion" } } })
             --     -- Add keybindings for CMP completion if needed
             -- end
        end
    },

    -- Minuet AI (Inline Autocompletion - Alternative/Complementary)
    {
        "milanglacier/minuet-ai.nvim",
        enabled = false, -- Disabled by default, enable if preferred over CodeCompanion inline
        event = "InsertEnter", -- Load when entering insert mode
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "hrsh7th/nvim-cmp" }, -- Required for CMP frontend
            { "Davidyz/VectorCode" }, -- For codebase context
        },
        config = function()
            local minuet = require("minuet")
            local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()

            -- Function to get VectorCode context for Minuet prompts
            local function get_repo_context()
                 local prompt_message = ''
                 -- Adjust n_query as needed (0 means use default)
                 local cache_result = vectorcode_cacher.query_from_cache(0, { notify = false })
                 if not cache_result then return '' end

                 for _, file in ipairs(cache_result) do
                     prompt_message = prompt_message
                         .. '<file_separator path="' .. file.path .. '">\n'
                         .. file.document .. '\n'
                         .. '</file_separator>\n'
                 end

                 if prompt_message ~= '' then
                     prompt_message = '<repo_context>\n' .. prompt_message .. '</repo_context>'
                 end
                 return prompt_message
            end

            minuet.setup {
                -- General settings
                add_single_line_entry = true, -- Show single-line suggestions in CMP
                n_completions = 1,         -- Number of suggestions to fetch
                -- context_window = 2048,  -- Adjust based on model/performance
                after_cursor_filter_length = 100, -- Characters after cursor to consider
                notify = "warn", -- Log level (debug, info, warn, error)

                -- Frontend configuration (using nvim-cmp)
                cmp = {
                    enable_auto_complete = true, -- Enable auto-completion via CMP
                },
                -- Provider configuration (Gemini example)
                provider = "gemini",
                provider_options = {
                    gemini = {
                        max_tokens = 512,
                        model = gemini_model,
                        stream = true, -- Use streaming for faster feedback
                        api_key = "GEMINI_API_KEY", -- Use environment variable
                        -- System prompt template
                        system = {
                            template = '{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}',
                            repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
                        },
                        -- Input prompt template including repo context
                        chat_input = {
                            template = '{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}',
                            repo_context = get_repo_context, -- Function to fetch context
                        },
                    },
                    -- Add Claude configuration similar to Gemini if needed
                    claude = {
                         max_tokens = 512,
                         model = claude_model,
                         stream = true,
                         api_key = "ANTHROPIC_API_KEY",
                         system = { -- Similar template as Gemini
                             template = '{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}',
                             repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
                         },
                         chat_input = { -- Similar template as Gemini
                             template = '{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}',
                             repo_context = get_repo_context,
                         },
                     },
                } -- End provider_options
            } -- End minuet.setup

            -- CMP source configuration for Minuet
            local cmp_ok, cmp = pcall(require, "cmp")
            if cmp_ok then
                 cmp.setup.buffer({
                     sources = cmp.config.sources({
                         { name = "minuet" }, -- Add Minuet source
                         -- Add other CMP sources (nvim_lsp, luasnip, buffer, path, etc.)
                         { name = "nvim_lsp" },
                         -- { name = "luasnip" },
                         { name = "buffer" },
                         { name = "path" },
                     })
                 })
                 -- Configure keybindings for CMP accept/scroll if not already set
                 -- vim.keymap.set("i", "<Tab>", cmp.mapping.select_next_item(), { noremap = true, silent = true })
                 -- vim.keymap.set("i", "<S-Tab>", cmp.mapping.select_prev_item(), { noremap = true, silent = true })
                 -- vim.keymap.set("i", "<CR>", cmp.mapping.confirm({ select = true }), { noremap = true, silent = true })
            end
        end, -- End config function
    }, -- End Minuet block
} -- End return table
