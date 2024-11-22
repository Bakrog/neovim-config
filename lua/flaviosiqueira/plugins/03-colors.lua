function BackgroundTransparency(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    -- If you like transparent background, uncomment this
    --vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    "rose-pine/neovim",
    name = "rose-pine",
    enabled = true,
    config = function()
        require("rose-pine").setup({
            --background = "none",
            dim_inactive_windows = true,
            extend_background_behind_borders = true,
            enable = {
                terminal = true,
                migrations = true,
            },
            styles = {
                italic = true,
                bold = true,
                transparency = true,
            },
            highlight_groups = {
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
        vim.cmd("colorscheme rose-pine")
        BackgroundTransparency()
    end
}
