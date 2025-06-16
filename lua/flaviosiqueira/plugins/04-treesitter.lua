-- lua/flaviosiqueira/plugins/04-treesitter.lua
-- Treesitter configuration for syntax highlighting and more
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",                    -- Command to update parsers
    event = { "BufReadPre", "BufNewFile" }, -- Load early for highlighting/indent
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = { -- List of languages to install parsers for
                "bash",
                "elixir",
                "heex",
                "html",
                "java",
                "javascript",
                "jsdoc",
                "kotlin",
                "lua",
                "python",
                "query",
                "regex",
                "rust",
                "typescript",
                "vim",
                "vimdoc",
                "markdown",        -- Added markdown here
                "markdown_inline", -- For inline markdown highlighting
                "json",
                "yaml",
                "toml",
                "go",
                "templ", -- Added templ here
                "zig",
            },
            sync_install = false,                          -- Install parsers asynchronously
            auto_install = true,                           -- Automatically install missing parsers
            highlight = {
                enable = true,                             -- Enable syntax highlighting
                additional_vim_regex_highlighting = false, -- Use Treesitter primarily
            },
            indent = { enable = true },                    -- Enable Treesitter-based indentation
            -- Other modules can be enabled here (e.g., incremental selection)
        })

        -- Custom parser configuration for templ
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.templ = {
            install_info = {
                url = "https://github.com/vrischmann/tree-sitter-templ.git",
                files = { "src/parser.c", "src/scanner.c" },
                branch = "master",
                -- generate_requires_npm = false, -- Uncomment if it requires npm build steps
                -- requires_generate_from_grammar = false, -- Uncomment if grammar needs generation
            },
            filetype = "templ", -- Associate with templ filetype
        }
        -- No need to register language manually if filetype is set in install_info
    end
}
