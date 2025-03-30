-- lua/flaviosiqueira/plugins/01-colors.lua
-- Rose Pine theme configuration
return {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false, -- Load theme immediately
    priority = 1000, -- Ensure it loads before other plugins
    dependencies = { "rcarriga/nvim-notify" },
    config = function()
        require("rose-pine").setup({
            dim_inactive_windows = true,
            extend_background_behind_borders = true,
            enable = {
                terminal = true,
                migrations = true,
            },
            styles = {
                italic = true,
                bold = true,
                transparency = true, -- Keep background transparent
            },
            highlight_groups = {
                -- Custom highlights for Telescope, Search, etc.
                TelescopeBackground = { bg = "none", fg = "none" },
                TelescopeBorder = { fg = "highlight_high", bg = "none" },
                TelescopeNormal = { bg = "none" },
                TelescopePromptNormal = { bg = "base" },
                TelescopeResultsNormal = { fg = "subtle", bg = "none" },
                TelescopeSelection = { fg = "text", bg = "base" },
                TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
                CurSearch = { fg = "base", bg = "rose", inherit = false },
                Search = { bg = "rose", blend = 20, inherit = false },
            },
        })
        -- Set the colorscheme
        vim.cmd.colorscheme("rose-pine")

        -- Configure nvim-notify with theme colors
        require("notify").setup({
            stages = "fade",
            timeout = 5000,
            background_colour = "#1f1d2e", -- Rose Pine base color
            merge_duplicates = true,
            icons = {
                ERROR = "",
                WARN = "",
                INFO = "",
                DEBUG = "",
                TRACE = "✎",
            },
        })
    end
}
