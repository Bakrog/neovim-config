return {
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons" },
    dependencies = { "folke/noice.nvim", {"Davidyz/VectorCode", lazy = false} },

    config = function()
        require("lualine").setup({
            options = {
                theme = "rose-pine",
                section_separators = { "", "" },
                component_separators = { "", "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = { "filename" },
                lualine_j = {
                    {
                        require("noice").api.status.message.get_hl,
                        cond = require("noice").api.status.message.has,
                    },
                    {
                        require("noice").api.status.command.get,
                        cond = require("noice").api.status.command.has,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        require("noice").api.status.mode.get,
                        cond = require("noice").api.status.mode.has,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        require("noice").api.status.search.get,
                        cond = require("noice").api.status.search.has,
                        color = { fg = "#ff9e64" },
                    },
                },
                lualine_x = {
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
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {
                lualine_y = {
                    {
                        function()
                            return require("vectorcode.integrations").lualine(opts)[1]()
                        end,
                        cond = function()
                            if package.loaded["vectorcode"] == nil then
                                return false
                            else
                                return require("vectorcode.integrations").lualine(opts).cond()
                            end
                        end,
                    },
                }
            },
            extensions = {
                "nvim-dap-ui",
                "fugitive",
                "fzf",
                "lazy",
                "mason",
                "trouble",
            },
        })
    end
}
