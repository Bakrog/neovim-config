return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "bash",
                "elixir",
                "heex",
                "html",
                "javascript",
                "jsdoc",
                "lua",
                "python",
                "query",
                "rust",
                "typescript",
                "vim",
                "vimdoc",
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "markdown" },
            },
            indent = { enable = true },
        })
    end
}

