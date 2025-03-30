-- lua/flaviosiqueira/plugins/02-lualine.lua
-- Status line configuration
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",        -- Required for icons
        "folke/noice.nvim",                   -- Integration for Noice UI
        { "Davidyz/VectorCode", lazy = true } -- Optional VectorCode integration
    },
    event = "VeryLazy",                       -- Load Lualine lazily
    config = function()
        local vectorcode_lualine = {          -- Placeholder if VectorCode not available
            function()
                return ""
            end,
            cond = function()
                return false
            end,
        }
        local vectorcode_loaded, vectorcode = pcall(require, "vectorcode.integrations")
        if vectorcode_loaded and vectorcode.lualine then
            local vc_opts = {} -- Add VectorCode opts if necessary
            vectorcode_lualine = {
                function()
                    return vectorcode.lualine(vc_opts)[1]()
                end,
                cond = function()
                    return vectorcode.lualine(vc_opts).cond()
                end,
            }
        end


        require("lualine").setup({
            options = {
                theme = "rose-pine", -- Match colorscheme
                section_separators = { "", "" },
                component_separators = { "", "" },
                disabled_filetypes = { -- Disable for specific views
                    statusline = { "dashboard", "alpha" },
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false, -- Use per-window statuslines
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff" },
                lualine_c = { { "filename", path = 1 } }, -- Show relative path
                lualine_x = {
                    {                                     -- Noice command status
                        require("noice").api.status.command.get,
                        cond = require("noice").api.status.command.has,
                        color = { fg = "#ff9e64" },
                    },
                    { -- Noice mode status
                        require("noice").api.status.mode.get,
                        cond = require("noice").api.status.mode.has,
                        color = { fg = "#ff9e64" },
                    },
                    "diagnostics",
                    "encoding",
                    "fileformat",
                    "filetype",
                },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { { "filename", path = 1 } }, -- Show relative path
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {
                --lualine_a = { 'buffers' },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = { vectorcode_lualine }, -- VectorCode status
                lualine_z = { 'tabs' }
            },
            winbar = {},
            inactive_winbar = {},
            extensions = { -- Enable extensions for integrations
                "nvim-dap-ui",
                "fugitive",
                "fzf",
                "lazy",
                "mason",
                "trouble",
                "nvim-tree", -- Assuming nvim-tree might be used
            },
        })
    end
}
