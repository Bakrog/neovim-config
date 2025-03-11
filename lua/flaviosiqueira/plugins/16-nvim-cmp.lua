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
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        keys = {
            {
                "nh",
                "<cmd>Noice telescope<cr>",
                mode = { "n" },
            },
        },
        opts = {
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    --{                                        -- optional cmp completion source for require statements and module annotations
    --    "hrsh7th/nvim-cmp",
    --    keys = {},
    --    opts = function(_, opts)
    --        opts.sources = opts.sources or {}
    --        opts.performance = opts.performance or {}
    --        table.insert(opts.sources, {
    --            name = "lazydev",
    --            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
    --        })
    --        table.insert(opts.sources, { name = "minuet" })
    --        opts.performance.fetching_timeout = 2000
    --    end,
    --},
    { -- optional blink completion source for require statements and module annotations
        "saghen/blink.cmp",
        version = '*',
        -- In case there are breaking changes and you want to go back to the last
        -- working release
        -- https://github.com/Saghen/blink.cmp/releases
        -- version = "v0.9.3",
        dependencies = {
            "moyiz/blink-emoji.nvim",
            "onsails/lspkind.nvim",
        },
        keys = {},
        opts = {
            enabled = function()
                -- Get the current buffer's filetype
                local filetype = vim.bo[0].filetype
                -- Disable for Telescope buffers
                if filetype == "TelescopePrompt" or filetype == "minifiles" or filetype == "snacks_picker_input" then
                    return false
                end
                return true
            end,
            sources = {
                -- add lazydev to your completion providers
                default = { "lsp", "path", "snippets", "buffer", "lazydev", "dadbod", "emoji" },
                providers = {
                    cmdline = {
                        enabled = function()
                            local type = vim.fn.getcmdtype()
                            -- Search forward and backward
                            if type == "/" or type == "?" then
                                return { "buffer" }
                            end
                            -- Commands
                            if type == ":" then
                                return { "cmdline" }
                            end
                            return {}
                        end,
                    },
                    lsp = {
                        name = "lsp",
                        module = "blink.cmp.sources.lsp",
                        min_keyword_length = 2,
                        -- When linking markdown notes, I would get snippets and text in the
                        -- suggestions, I want those to show only if there are no LSP
                        -- suggestions
                        --
                        -- Enabled fallbacks as this seems to be working now
                        -- Disabling fallbacks as my snippets wouldn't show up when editing
                        -- lua files
                        -- fallbacks = { "snippets", "buffer" },
                        score_offset = 0, -- the higher the number, the higher the priority
                    },
                    path = {
                        name = "Path",
                        module = "blink.cmp.sources.path",
                        -- When typing a path, I would get snippets and text in the
                        -- suggestions, I want those to show only if there are no path
                        -- suggestions
                        min_keyword_length = 0,
                        opts = {
                            trailing_slash = false,
                            label_trailing_slash = true,
                            --get_cwd = function(context)
                            --    return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                            --end,
                            show_hidden_files_by_default = true,
                        },
                    },
                    buffer = {
                        name = "Buffer",
                        max_items = 5,
                        module = "blink.cmp.sources.buffer",
                        min_keyword_length = 5,
                    },
                    snippets = {
                        name = "snippets",
                        enabled = true,
                        max_items = 15,
                        min_keyword_length = 2,
                        module = "blink.cmp.sources.snippets",
                        -- Only show snippets if I type the trigger_text characters, so
                        -- to expand the "bash" snippet, if the trigger_text is ";" I have to
                        --should_show_items = function()
                        --    local col = vim.api.nvim_win_get_cursor(0)[2]
                        --    local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
                        --    -- NOTE: remember that `trigger_text` is modified at the top of the file
                        --    return before_cursor:match(trigger_text .. "%w*$") ~= nil
                        --end,
                        -- After accepting the completion, delete the trigger_text characters
                        -- from the final inserted text
                        -- Modified transform_items function based on suggestion by `synic` so
                        -- that the luasnip source is not reloaded after each transformation
                        -- https://github.com/linkarzu/dotfiles-latest/discussions/7#discussion-7849902
                        --transform_items = function(_, items)
                        --    local col = vim.api.nvim_win_get_cursor(0)[2]
                        --    local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
                        --    local trigger_pos = before_cursor:find(trigger_text .. "[^" .. trigger_text .. "]*$")
                        --    if trigger_pos then
                        --        for _, item in ipairs(items) do
                        --            if not item.trigger_text_modified then
                        --                ---@diagnostic disable-next-line: inject-field
                        --                item.trigger_text_modified = true
                        --                item.textEdit = {
                        --                    newText = item.insertText or item.label,
                        --                    range = {
                        --                        start = { line = vim.fn.line(".") - 1, character = trigger_pos - 1 },
                        --                        ["end"] = { line = vim.fn.line(".") - 1, character = col },
                        --                    },
                        --                }
                        --            end
                        --        end
                        --    end
                        --    return items
                        --end,
                    },
                    -- Example on how to configure dadbod found in the main repo
                    -- https://github.com/kristijanhusak/vim-dadbod-completion
                    dadbod = {
                        name = "Dadbod",
                        module = "vim_dadbod_completion.blink",
                        min_keyword_length = 2,
                    },
                    -- https://github.com/moyiz/blink-emoji.nvim
                    emoji = {
                        module = "blink-emoji",
                        name = "Emoji",
                        min_keyword_length = 2,
                        opts = { insert = true }, -- Insert emoji (default) or complete its name
                    },
                    -- https://github.com/Kaiser-Yang/blink-cmp-dictionary
                    -- In macOS to get started with a dictionary:
                    -- cp /usr/share/dict/words ~/github/dotfiles-latest/dictionaries/words.txt
                    --
                    -- NOTE: For the word definitions make sure "wn" is installed
                    -- brew install wordnet
                    --dictionary = {
                    --    module = "blink-cmp-dictionary",
                    --    name = "Dict",
                    --    score_offset = 20, -- the higher the number, the higher the priority
                    --    -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
                    --    enabled = true,
                    --    max_items = 8,
                    --    min_keyword_length = 3,
                    --    opts = {
                    --        -- -- The dictionary by default now uses fzf, make sure to have it
                    --        -- -- installed
                    --        -- -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
                    --        --
                    --        -- Do not specify a file, just the path, and in the path you need to
                    --        -- have your .txt files
                    --        dictionary_directories = { vim.fn.expand("~/.github/dotfiles-latest/dictionaries") },
                    --        -- Notice I'm also adding the words I add to the spell dictionary
                    --        dictionary_files = {
                    --            vim.fn.expand("~/.github/dotfiles-latest/neovim/neobean/spell/en.utf-8.add"),
                    --            vim.fn.expand("~/.github/dotfiles-latest/neovim/neobean/spell/es.utf-8.add"),
                    --        },
                    --        -- --  NOTE: To disable the definitions uncomment this section below
                    --        --
                    --        -- separate_output = function(output)
                    --        --   local items = {}
                    --        --   for line in output:gmatch("[^\r\n]+") do
                    --        --     table.insert(items, {
                    --        --       label = line,
                    --        --       insert_text = line,
                    --        --       documentation = nil,
                    --        --     })
                    --        --   end
                    --        --   return items
                    --        -- end,
                    --    },
                    --},
                    -- dont show LuaLS require statements when lazydev has items
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                    },
                    minuet = {
                        name = "minuet",
                        enabled = false,
                        module = "minuet.blink",
                        score_offset = 100,
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
                use_nvim_cmp_as_default = false,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },
            --fuzzy = { implementation = "prefer_rust" },
            completion = {
                accept = { auto_brackets = { enabled = true } },
                menu = {
                    border = "rounded",

                    cmdline_position = function()
                        if vim.g.ui_cmdline_pos ~= nil then
                            local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                            return { pos[1] - 1, pos[2] }
                        end
                        local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                        return { vim.o.lines - height, 0 }
                    end,

                    draw = {
                        columns = {
                            { "kind_icon", "label", gap = 1 },
                            { "kind" },
                        },
                        components = {
                            kind_icon = {
                                text = function(item)
                                    local kind = require("lspkind").symbol_map[item.kind] or ""
                                    return kind .. " "
                                end,
                                highlight = "CmpItemKind",
                            },
                            label = {
                                text = function(item)
                                    return item.label
                                end,
                                highlight = "CmpItemAbbr",
                            },
                            kind = {
                                text = function(item)
                                    return item.kind
                                end,
                                highlight = "CmpItemKind",
                            },
                        },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 250,
                    treesitter_highlighting = true,
                    window = {
                        border = "rounded",
                    },
                },
                -- Displays a preview of the selected item on the current line
                ghost_text = {
                    enabled = false,
                },
                trigger = {
                    prefetch_on_insert = false
                }
            },
            snippets = {
                preset = "luasnip", -- Choose LuaSnip as the snippet engine
            },
            keymap = {
                preset = "default",
                ["<Tab>"] = { "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },

                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },

                ["<S-k>"] = { "scroll_documentation_up", "fallback" },
                ["<S-j>"] = { "scroll_documentation_down", "fallback" },

                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
            },
            -- Experimental signature help support
            signature = {
                enabled = true,
                window = { border = "rounded" },
            },
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
