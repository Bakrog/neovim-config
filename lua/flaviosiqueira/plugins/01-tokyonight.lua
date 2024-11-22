return {
    "folke/tokyonight.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    ops = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        transparent = true, -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
            -- Style to be applied to different syntax groups
            -- Value is any valid attr-list value for `:help nvim_set_hl`
            comments = { italic = false },
            keywords = { italic = false },
            -- Background styles. Can be "dark", "transparent" or "normal"
            sidebars = "dark", -- style for sidebars, see below
            floats = "dark", -- style for floating windows
        },
        on_highlights = function(hl, c)
            local prompt = "#2d3149"
            --local prompt = "none"
            hl.TelescopeNormal = {
                bg = c.bg_dark,
                fg = c.fg_dark,
            }
            hl.TelescopeBorder = {
                bg = c.bg_dark,
                fg = c.fg_dark,
            }
            hl.TelescopePromptNormal = {
                bg = prompt,
            }
            hl.TelescopePromptBorder = {
                bg = prompt,
                fg = prompt,
            }
            hl.TelescopePromptTitle = {
                bg = prompt,
                fg = prompt,
            }
            hl.TelescopePreviewTitle = {
                bg = c.bg_dark,
                fg = c.fg_dark,
            }
            hl.TelescopeResultsTitle = {
                bg = c.bg_dark,
                fg = c.fg_dark,
            }
        end,
    },
}
