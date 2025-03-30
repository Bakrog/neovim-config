-- lua/flaviosiqueira/plugins/12-sql.lua
-- Database UI and query tools
return {
    "kristijanhusak/vim-dadbod-ui",
    -- Load when DBUI commands are used
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = {
        -- Core dadbod plugin
        { "tpope/vim-dadbod", lazy = true },
        -- Completion for SQL
        { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        -- Optional: WhichKey integration for easier command discovery
        -- { "folke/which-key.nvim", optional = true },
    },
    init = function()
        -- Define global variables or settings for dadbod if needed
        -- vim.g.db_ui_use_nerd_fonts = 1 -- Use nerd fonts if available
        vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_connections.json"
        vim.g.db_ui_auto_execute_table_helpers = 1 -- Auto-execute helpers like describe table
        vim.g.db_ui_show_database_icon = true
    end,
    config = function()
        -- Setup WhichKey mappings if WhichKey is loaded
        if package.loaded["which-key"] then
            local wk = require("which-key")
            wk.register({
                ["<leader>db"] = { name = "+Database" },
                ["<leader>dbu"] = { "<cmd>DBUIToggle<cr>", "Toggle DB UI" },
                ["<leader>dbr"] = { "<cmd>DBUIRenameBuffer<cr>", "Rename DB Buffer" },
                ["<leader>dbs"] = { "<cmd>DBUISave<cr>", "Save DB Connection" },
                ["<leader>dbc"] = { "<cmd>DBUIAddConnection<cr>", "Add DB Connection" },
                ["<leader>dbf"] = { "<cmd>DBUIFindBuffer<cr>", "Find DB Buffer" },
            })
        end
    end,
}
