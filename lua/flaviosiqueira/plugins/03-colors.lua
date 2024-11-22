local function BackgroundTransparency(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    -- If you like transparent background, uncomment this
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0,"TelescopeNormal",{bg="none"})
end

return {
    "rose-pine/neovim",
    name = "rose-pine",
    enabled = true,
    config = function()
        require("rose-pine").setup({
            background = "none",
        })
        vim.cmd("colorscheme tokyonight")
        --vim.cmd("colorscheme rose-pine")
        BackgroundTransparency("tokyonight")
    end
}
