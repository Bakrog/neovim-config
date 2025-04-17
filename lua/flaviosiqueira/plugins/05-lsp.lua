-- lua/flaviosiqueira/pluginsu05-lsp.lua
-- LSP (Language Server Protocol) configuration
return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" }, -- Trigger LSP loading on buffer events
        dependencies = {
            -- Mason for managing LSP servers, DAP adapters, linters, formatters
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- LSP progress indicator
            "j-hui/fidget.nvim",

            -- Folding support using UFO
            {
                "kevinhwang91/nvim-ufo",
                dependencies = { "kevinhwang91/promise-async" },
                event = "BufReadPost", -- Load UFO slightly later
                opts = {
                    provider_selector = function(bufnr, filetype, buftype)
                        -- Enable LSP folding provider primarily
                        return { "lsp", "indent" }
                    end,
                    -- Configure preview window appearance
                    preview = {
                        win_config = {
                            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                            winhighlight = "Normal:Folded",
                            winblend = 0,
                        },
                        mappings = {
                            jumpTop = "[",
                            jumpBot = "]",
                        },
                    },
                    -- Customize the text shown for folded regions
                    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                        local newVirtText = {}
                        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                        local sufWidth = vim.fn.strdisplaywidth(suffix)
                        local targetWidth = width - sufWidth
                        local curWidth = 0
                        for _, chunk in ipairs(virtText) do
                            local chunkText = chunk[1]
                            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                            if targetWidth > curWidth + chunkWidth then
                                table.insert(newVirtText, chunk)
                            else
                                chunkText = truncate(chunkText, targetWidth - curWidth)
                                local hlGroup = chunk[2]
                                table.insert(newVirtText, { chunkText, hlGroup })
                                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                                if curWidth + chunkWidth < targetWidth then
                                    suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                                end
                                break
                            end
                            curWidth = curWidth + chunkWidth
                        end
                        table.insert(newVirtText, { suffix, "MoreMsg" })
                        return newVirtText
                    end,
                },
                init = function()
                    -- Define folding keymaps
                    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "UFO: Open All Folds" })
                    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "UFO: Close All Folds" })
                    vim.keymap.set(
                        "n",
                        "zr",
                        require("ufo").openFoldsExceptKinds,
                        { desc = "UFO: Open Folds Except Kinds" }
                    )
                    vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "UFO: Close Folds With" })
                    -- Optional: Use treesitter folds for some filetypes
                    -- vim.o.foldmethod = 'expr'
                    -- vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
                    vim.o.foldlevel = 99
                end,
            },

            -- Crates.nvim for Rust dependency management in Cargo.toml
            {
                "saecki/crates.nvim",
                ft = { "rust", "toml" }, -- Load specifically for rust/toml files
                config = function()
                    require("crates").setup({
                        lsp = { enabled = true, actions = true, completion = true, hover = true },
                    })
                    -- Optionally show crates info automatically or via command
                    -- require("crates").show()
                end,
            },

            -- Luasnip
            {
                "L3MON4D3/LuaSnip",
                -- follow latest release.
                version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
                -- install jsregexp (optional!).
                build = "make install_jsregexp",
            },

            "saghen/blink.cmp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local mason_lspconfig = require("mason-lspconfig")

            -- Setup Fidget for LSP progress
            require("fidget").setup({})

            -- Setup Mason
            require("mason").setup({})

            -- Get default LSP capabilities (will be modified by rustaceanvim if active)
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                require("blink.cmp").get_lsp_capabilities()
            )
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }

            -- List of servers to ensure are installed by Mason
            local ensure_installed_servers = {
                "ansiblels",
                "basedpyright",
                "docker_compose_language_service",
                "dockerls",
                "eslint",
                "intelephense",
                "kotlin_language_server",
                "lua_ls",
                "marksman",
                -- "rust_analyzer", -- Handled by rustaceanvim
                "tflint",
                "ts_ls",
                "ruff",
                "zls",   -- Zig Language Server
                "gopls", -- Go Language Server
                "templ", -- Templ Language Server
                -- Add other servers as needed
            }

            mason_lspconfig.setup({
                ensure_installed = ensure_installed_servers,
                automatic_installation = true, -- Automatically install servers on setup
            })

            -- Custom LSP setup handlers
            local handlers = {
                -- Default handler: Setup server with capabilities
                function(server_name)
                    -- Skip rust-analyzer if rustaceanvim is handling it
                    if server_name == "rust_analyzer" and vim.g.rustaceanvim then
                        return
                    end
                    -- Skip vectorcode_server if handled elsewhere
                    if server_name == "vectorcode_server" then
                        return
                    end

                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                        on_attach = function(client, bufnr)
                            -- Common on_attach function (can be moved to 99-autocmds.lua)
                            -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) -- Enable globally or per-server
                            -- Define keymaps in 99-autocmds.lua using LspAttach event
                        end,
                    })
                end,

                -- Specific setup for lua_ls (Neovim's Lua LSP)
                lua_ls = function()
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "LuaJIT" },
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each", "require" },
                                },
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true),
                                    checkThirdParty = false, -- Improve performance
                                },
                                telemetry = { enable = false },
                            },
                        },
                    })
                end,

                -- Specific setup for ruff-lsp (Python Linter/Formatter LSP)
                ruff = function()
                    lspconfig.ruff.setup({
                        capabilities = capabilities,
                        init_options = {
                            settings = {
                                -- Example: Configure lint rules if needed
                                -- lint = { select = {"E", "F", "W"} }
                            },
                        },
                        -- on_attach function can be defined here or globally
                    })
                end,

                -- Specific setup for ts_ls (TypeScript/JavaScript LSP)
                ["ts_ls"] = function()
                    lspconfig.ts_ls.setup({
                        capabilities = capabilities,
                        init_options = {
                            preferences = {
                                importModuleSpecifierPreference = "relative",
                                includePackageJsonAutoImports = "auto",
                            },
                        },
                        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
                        filetypes = {
                            "javascript",
                            "javascriptreact",
                            "javascript.jsx",
                            "typescript",
                            "typescriptreact",
                            "typescript.tsx",
                            "mjs",
                            "cjs",
                        },
                    })
                end,

                -- Setup for eslint (Separate Linter/Formatter LSP for JS/TS)
                eslint = function()
                    lspconfig.eslint.setup({
                        capabilities = capabilities,
                        root_dir = lspconfig.util.root_pattern(
                            ".eslintrc.js",
                            ".eslintrc.cjs",
                            ".eslintrc.json",
                            "eslint.config.js",
                            "package.json"
                        ),
                        settings = {
                            -- ESLint settings can be customized here
                            run = "onType",
                            format = true, -- Enable formatting via ESLint
                        },
                        filetypes = {
                            "javascript",
                            "javascriptreact",
                            "javascript.jsx",
                            "typescript",
                            "typescriptreact",
                            "typescript.tsx",
                            "mjs",
                            "cjs",
                            "html",
                            "vue",
                        }, -- Add relevant filetypes
                    })
                end,

                -- Setup for basedpyright (Python Type Checker / LSP)
                basedpyright = function()
                    lspconfig.basedpyright.setup({
                        capabilities = capabilities,
                        -- You might not need to specify the command if Mason handles it
                        -- cmd = { vim.fn.stdpath("data") .. "/mason/bin/basedpyright-langserver", "--stdio" },
                        on_attach = function(client, bufnr)
                            -- Disable Pyright hover if Ruff provides better info or if preferred
                            -- client.server_capabilities.hoverProvider = false
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end,
                        settings = {
                            basedpyright = {
                                analysis = {
                                    diagnosticMode = "openFilesOnly", -- Or "workspace"
                                    -- Optional: specify python environment
                                    -- venvPath = ".", venv = ".venv"
                                },
                            },
                            python = {
                                analysis = {
                                    -- autoSearchPaths = true, useLibraryCodeForTypes = true
                                },
                            },
                        },
                    })
                end,
                -- Add other custom handlers here (e.g., kotlin_language_server, zls)
                kotlin_language_server = function()
                    lspconfig.kotlin_language_server.setup({
                        capabilities = capabilities,
                        on_attach = function(_, bufnr)
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end,
                        -- Command might be handled by Mason, otherwise specify path
                        -- cmd = { vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/kls/server/build/install/server/bin/kotlin-language-server") },
                        root_dir = lspconfig.util.root_pattern("build.gradle", "build.gradle.kts", ".git"),
                        init_options = {
                            storagePath = vim.fn.resolve(vim.fn.stdpath("cache") .. "/kotlin_language_server"),
                        },
                    })
                end,
                zls = function()
                    lspconfig.zls.setup({
                        capabilities = capabilities,
                        -- Command might be handled by Mason
                        -- cmd = { vim.fn.stdpath("data") .. "/mason/bin/zls" },
                    })
                end,
                templ = function()
                    lspconfig.templ.setup({
                        capabilities = capabilities,
                        filetypes = { "templ", "html" }, -- Associate with .templ files
                    })
                end,
                gopls = function()
                    lspconfig.gopls.setup({
                        capabilities = capabilities,
                        settings = {
                            gopls = {
                                gofumpt = true,     -- Use gofumpt formatting
                                staticcheck = true, -- Enable staticcheck analysis
                            },
                        },
                    })
                end,
            }

            -- Apply the handlers
            mason_lspconfig.setup_handlers(handlers)

            -- Mason Tool Installer setup (for linters, formatters, debuggers)
            require("mason-tool-installer").setup({
                ensure_installed = {
                    -- Debuggers
                    "codelldb",         -- LLDB DAP adapter
                    "debugpy",          -- Python DAP adapter (used by nvim-dap-python)
                    "js-debug-adapter", -- JS/TS DAP adapter

                    -- Linters / Formatters
                    "ktlint",        -- Kotlin linter/formatter
                    "prettier",      -- Code formatter (JS, TS, JSON, CSS, MD, etc.)
                    "stylua",        -- Lua formatter
                    "shfmt",         -- Shell script formatter
                    "shellcheck",    -- Shell script linter
                    "sqlfluff",      -- SQL linter/formatter
                    "gofumpt",       -- Go formatter
                    "goimports",     -- Go imports tool
                    "golangci-lint", -- Go linter suite
                    "staticcheck",   -- Go static analyzer
                    "yamllint",      -- YAML linter
                    "black",         -- Python formatter
                    "isort",         -- Python import sorter
                    "flake8",        -- Python linter (consider using just Ruff)
                },
                auto_update = true,  -- Set to true to auto-update tools
                run_on_start = true, -- Install tools on startup if missing
            })

            -- Global diagnostic configuration
            vim.diagnostic.config({
                virtual_text = true, -- Show diagnostics inline (consider false if too noisy)
                signs = true,
                underline = true,
                update_in_insert = false, -- Don't update diagnostics while typing
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always", -- Show the source of the diagnostic (e.g., "eslint")
                    header = "",
                    prefix = "",
                },
            })

            -- Set sign priority for diagnostics
            vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
            vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
            vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

            -- Configure folding appearance
            vim.opt.foldcolumn = "1"
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            vim.opt.foldenable = true -- UFO requires folding to be enabled
        end,                          -- End of main config function
    },                                -- End of nvim-lspconfig block
    -- Rustaceanvim (alternative/enhanced Rust LSP setup) - KEEP THIS
    {
        "mrcjkb/rustaceanvim",
        version = "^5",              -- Use a stable version
        lazy = false,
        ft = { "rust" },             -- Load specifically for Rust files
        dependencies = {
            "neovim/nvim-lspconfig", -- Already listed, but good practice
            "mfussenegger/nvim-dap", -- For DAP integration
            "saghen/blink.cmp",
        },
        config = function()
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                require("blink.cmp").get_lsp_capabilities()
            )
            -- Add folding capabilities if using UFO or similar
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = true,
                lineFoldingOnly = true,
            }

            local codelldb_path, liblldb_path = nil, nil
            -- Attempt to find codelldb via mason-tool-installer path
            local mason_registry = require("mason-registry")
            local has_codelldb, codelldb_pkg = pcall(mason_registry.get_package, "codelldb")
            if has_codelldb then
                local install_dir = codelldb_pkg:get_install_path()
                codelldb_path = install_dir .. "/extension/adapter/codelldb"
                liblldb_path = install_dir .. "/extension/lldb/lib/liblldb.dylib" -- Adjust for OS if needed
            else
                vim.notify("Mason codelldb package not found", vim.log.levels.ERROR);
                return
            end

            vim.g.rustaceanvim = {
                -- Use LSP capabilities
                capabilities = capabilities,
                lsp = {
                    auto_attach = true,
                    --standalone = false,
                },
                ra_multiplex = {
                    enable = true,
                },
                create_graph = {},
                server = {
                    on_attach = function(client, bufnr)
                        -- Enable inlay hints for Rust
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        -- Custom keymaps for Rust actions
                        vim.keymap.set("n", "<leader>ca", function()
                            vim.cmd.RustLsp("codeAction")
                        end, { silent = true, buffer = bufnr, desc = "Rust: Code Action" })
                        vim.keymap.set("n", "<leader>re", function()
                            vim.cmd.RustLsp("explainError")
                        end, { silent = true, buffer = bufnr, desc = "Rust: Explain Error" })
                        -- Add other LSP keymaps if not set globally in 99-autocmds.lua
                    end,
                    default_settings = {
                        ["rust-analyzer"] = {
                            -- Recommended settings for rust-analyzer
                            checkOnSave = true,
                            cargo = {
                                features = "all",
                                allTargets = true,
                                buildScripts = {
                                    enable = true,
                                },
                            },
                            check = {
                                command = "clippy",
                                workspace = true,
                            },
                            diagnostics = {
                                enable = true,
                                experimental = {
                                    enable = true,
                                },
                                styleLints = {
                                    enable = true,
                                },
                            },
                            inlayHints = {
                                lifetimeElisionHints = {
                                    enable = true,
                                    useParameterNames = true,
                                },
                            },
                            imports = {
                                granularity = {
                                    group = "module",
                                },
                                prefix = "self",
                            },
                            procMacro = {
                                enable = true,
                            },
                        },
                    },
                },
                dap = {
                    autoload_configurations = true,
                    adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path),
                    add_dynamic_library_paths = true,
                    auto_generate_source_map = true,
                    load_rust_types = true,
                },
                tools = {
                    autoSetHints = true,
                    hover_with_actions = true,
                    --test_executor = "background",
                    runnables = {
                        use_telescope = true,
                    },
                    debuggables = {
                        use_telescope = true,
                    },
                },
            }
        end,
    },
    -- Undotree
    {
        "mbbill/undotree",
        keys = {
            { "<leader>u", desc = "Undo history" }, -- Placeholder description, mapped below
        },

        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end,
    },
} -- End of return table
