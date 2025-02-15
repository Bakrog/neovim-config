-- Adding number suffix of folded lines instead of the default ellipsis
local handler = function(virtText, lnum, endLnum, width, truncate)
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
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
end

return {
    {
        "saecki/crates.nvim",
        ft = { "rust", "toml" },
        config = function()
            local crates = require("crates")
            crates.setup({
                lsp = {
                    enabled = true,
                    actions = true,
                    completion = true,
                    hover = true,
                },
            })
            crates.show()
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "j-hui/fidget.nvim",
            --"mfussenegger/nvim-jdtls",
            {
                "kotlin-community-tools/kotlin-language-server",
                name = "kls",
                build = "./gradlew :server:installDist",
            },
            {
                "kevinhwang91/nvim-ufo",
                name = "ufo",
                dependencies = {
                    "kevinhwang91/promise-async",
                },
                --event = "BufRead",
                opts = {
                    filetype_exclude = {
                        "help",
                        "alpha",
                        "dashboard",
                        "neo-tree",
                        "Trouble",
                        "lazy",
                        "mason"
                    },
                },
                keys = {
                    {
                        "zR",
                        function()
                            require("ufo").openAllFolds()
                        end,
                    },
                    {
                        "zM",
                        function()
                            require("ufo").closeAllFolds()
                        end,
                    },
                    {
                        "zr",
                        function()
                            require("ufo").openFoldsExceptKinds()
                        end,
                    },
                    {
                        "zm",
                        function()
                            require("ufo").closeFoldsWith()
                        end,
                    },
                },
                config = function()
                    local ufo = require("ufo")

                    ---@diagnostic disable-next-line: missing-fields
                    ufo.setup({
                        enable_get_fold_virt_text = false,
                        open_fold_hl_timeout = 150,
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
                        fold_virt_text_handler = handler,
                        provider_selector = function(bufnr, filetype, buftype)
                            return { "lsp", "marker" }
                        end,
                    })
                end
            }
        },

        config = function()
            local cmp = require('cmp')
            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
            )
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }

            require("fidget").setup({})
            require("mason").setup({
                registries = {
                    "github:mason-org/mason-registry",
                },
            })
            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = {
                    "ansiblels",
                    "basedpyright",
                    "denols",
                    "docker_compose_language_service",
                    "dockerls",
                    "eslint",
                    --"hadolint",
                    "intelephense",
                    --"jdtls",
                    "kotlin_language_server",
                    "lua_ls",
                    "marksman",
                    "rust_analyzer",
                    --"sqlfluff",
                    "tflint",
                    "ts_ls",
                    "ruff",
                    "zls",
                },
                handlers = {
                    function(server_name) -- default handler (optional)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities
                        })
                    end,

                    basedpyright = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.basedpyright.setup({
                            capabilities = capabilities,
                            cmd = {
                                vim.fn.stdpath("data") ..
                                "/mason/bin/basedpyright-langserver",
                                "--stdio",
                            },
                            on_attach = function(_, bufnr)
                                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                            end,
                            python = {
                                -- I always use this virtual environment
                                -- configuration, you can define it in your project
                                -- pyproject.toml file.
                                venv = ".venv",
                                venvPath = ".",
                            },
                            settings = {
                                basedpyright = {
                                    analysis = {
                                        diagnosticMode = "workspace",
                                    },
                                },
                            },
                        })
                    end,

                    -- jdtls = function()
                    --     local lspconfig = require("lspconfig")
                    --     lspconfig.jdtls.setup({
                    --         capabilities = capabilities,
                    --         on_attach = function(_, bufnr)
                    --             vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    --         end,
                    --         cmd = {
                    --             "jdtls",
                    --             "-configuration",
                    --             vim.fn.resolve(vim.fn.stdpath("config") .. "/jdtls/config"),
                    --             "-data",
                    --             vim.fn.resolve(vim.fn.stdpath("data") .. "/jdtls/data"),
                    --         },
                    --         root_dir = lspconfig.util.root_pattern("pom.xml", "gradle.build"),
                    --         init_options = {
                    --             workspace = vim.fn.resolve(vim.fn.stdpath("data") .. "/jdtls/data"),
                    --         }
                    --     })
                    -- end,

                    ["kotlin_language_server"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.kotlin_language_server.setup({
                            capabilities = capabilities,
                            on_attach = function(_, bufnr)
                                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                            end,
                            cmd = {
                                vim.fn.resolve(
                                    vim.fn.stdpath("data") ..
                                    "/lazy/kls/server/build/install/server/bin/kotlin-language-server"
                                ),
                            },
                            init_options = {
                                storagePath = vim.fn.resolve(
                                    vim.fn.stdpath("cache") .. "/kotlin_language_server"
                                )
                            },
                        })
                    end,

                    ["lua_ls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.lua_ls.setup({
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                                    }
                                }
                            }
                        })
                    end,

                    ["rust_analyzer"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.rust_analyzer.setup({
                            capabilities = capabilities,
                            on_attach = function(_, bufnr)
                                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                            end,
                            filetypes = { "rust" },
                            root_dir = lspconfig.util.root_pattern("Cargo.toml"),
                            settings = {
                                ["rust-analyzer"] = {
                                    cargo = {
                                        allFeatures = true,
                                        buildScripts = {
                                            enable = true,
                                        },
                                    },
                                    imports = {
                                        granularity = {
                                            group = "module",
                                        },
                                        prefix = "self",
                                    },
                                    interpret = {
                                        tests = true,
                                    },
                                    lens = {
                                        enable = true,
                                        debug = {
                                            enable = true,
                                        },
                                        implementations = {
                                            enable = true,
                                        },
                                    },
                                    procMacro = {
                                        enable = true
                                    },
                                }
                            }
                        })
                    end,

                    ["ts_ls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.ts_ls.setup({
                            capabilities = capabilities,
                            init_options = {
                                preferences = {
                                    importModuleSpecifierPreference = 'relative',
                                    includePackageJsonAutoImports = 'auto'
                                }
                            },
                            -- Add this to help resolve modules in pnpm
                            cmd = { "typescript-language-server", "--stdio" },
                            root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
                            -- Make sure TypeScript can find your project's dependencies
                            filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "mjs", "cjs" },
                        })
                    end,

                    eslint = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.eslint.setup({
                            -- This ensures ESLint can find your project's ESLint config
                            root_dir = require 'lspconfig'.util.root_pattern(
                                '.eslintrc',
                                '.eslintrc.js',
                                '.eslintrc.json'
                            ),
                            settings = {
                                codeAction = {
                                    disableRuleComment = {
                                        enable = true,
                                        location = "separateLine"
                                    },
                                    showDocumentation = {
                                        enable = true
                                    }
                                },
                                codeActionOnSave = {
                                    enable = false,
                                    mode = "all"
                                },
                                experimental = {
                                    useFlatConfig = false
                                },
                                format = true,
                                nodePath = "",
                                onIgnoredFiles = "off",
                                problems = {
                                    shortenToSingleLine = false
                                },
                                quiet = false,
                                rulesCustomizations = {},
                                run = "onType",
                                useESLintClass = false,
                                validate = "on",
                                workingDirectory = {
                                    mode = "auto"
                                },
                            },
                        })
                    end,

                    zls = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.zls.setup({
                            capabilities = capabilities,
                            cmd = {
                                vim.fn.stdpath("data") .. "/mason/bin/zls"
                            },
                        })
                    end,
                }
            })
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "codelldb",
                    "cpptools",
                    "js-debug-adapter",
                    "ktlint",
                    "prettier",
                    "sqlfluff",
                },
            })

            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'crates' },
                    { name = 'luasnip' }, -- For luasnip users.
                }, {
                    { name = 'buffer' },
                })
            })

            vim.diagnostic.config({
                -- update_in_insert = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })
        end
    },
    --{
    --    "mrcjkb/rustaceanvim",
    --    version = '^5', -- Recommended
    --    lazy = false,
    --    ft = { "rust" },
    --    dependencies = {
    --        "neovim/nvim-lspconfig",
    --        "mfussenegger/nvim-dap",
    --    },
    --    config = function()
    --        local cmp_lsp = require("cmp_nvim_lsp")
    --        local capabilities = vim.tbl_deep_extend(
    --            "force",
    --            {},
    --            vim.lsp.protocol.make_client_capabilities(),
    --            cmp_lsp.default_capabilities()
    --        )
    --        capabilities.textDocument.foldingRange = {
    --            dynamicRegistration = false,
    --            lineFoldingOnly = true
    --        }
    --        vim.g.rustaceanvim = {
    --            server = {
    --                capabilities = capabilities,
    --                on_attach = function(_, bufnr)
    --                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    --                end,
    --            },
    --            --dap = {
    --            --    autoload_configurations = true,
    --            --},
    --        }
    --    end
    --},
}
