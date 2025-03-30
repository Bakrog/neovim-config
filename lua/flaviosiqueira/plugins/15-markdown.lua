-- lua/flaviosiqueira/plugins/15-markdown.lua
-- Markdown preview and editing tools
return {
    {
        "OXY2DEV/markview.nvim",
        -- Load specifically for markdown and related filetypes
        ft = { "markdown", "md", "codecompanion" },
        -- Build step might be needed depending on the plugin version/setup
        -- build = ":UpdateRemotePlugins", -- Or specific build command if required
        opts = {
            -- Configuration options for MarkView
            preview = {
                -- Filetypes to activate preview for
                filetypes = { "markdown", "md", "codecompanion" },
                 -- Buffer types to ignore (e.g., terminal buffers)
                ignore_buftypes = {"terminal"},
            },
             -- Add other MarkView options as needed
             -- syntax_highlighting = true,
             -- syntect = true, -- Requires syntect binary
             -- katex = true, -- Requires katex binary
        },
        config = function(_, opts)
            require("markview").setup(opts)
            -- Optional: Add keymaps for MarkView commands if needed
            -- vim.keymap.set("n", "<leader>mvo", "<cmd>MarkviewOpen<cr>", {desc = "Open Markview Preview"})
            -- vim.keymap.set("n", "<leader>mvc", "<cmd>MarkviewClose<cr>", {desc = "Close Markview Preview"})
        end
    },
    -- Optional: Add other markdown related plugins here
    -- Example: vim-markdown for improved syntax highlighting/concealing
    -- {
    --    "preservim/vim-markdown",
    --    ft = {"markdown", "md"},
    --    init = function()
    --       vim.g.vim_markdown_folding_disabled = 1
    --       vim.g.vim_markdown_conceal = 0
    --    end
    -- },
    -- Example: markdown-preview.nvim (alternative previewer)
    -- {
    --     "iamcco/markdown-preview.nvim",
    --     cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    --     ft = { "markdown" },
    --     build = function() vim.fn["mkdp#util#install"]() end,
    -- }
}
