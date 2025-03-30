-- lua/flaviosiqueira/plugins/07-trouble.lua
-- Diagnostics viewer (alternative to quickfix list)
return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- For icons
    keys = {
        -- Toggle Trouble diagnostics window
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                                                            desc = "Diagnostics (Trouble)" },
        -- Toggle Trouble with filter for current buffer
        { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",                                               desc = "Buffer Diagnostics (Trouble)" },
        -- Toggle Trouble quickfix list
        { "<leader>xq", "<cmd>Trouble quickfix toggle<cr>",                                                               desc = "Quickfix List (Trouble)" },
        -- Toggle Trouble location list
        { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                                                                desc = "Location List (Trouble)" },
        -- Go to next item in Trouble list
        { "]t",         function() require("trouble").next({ mode = "diagnostics", skip_groups = true, jump = true }) end, desc = "Next Trouble Item" },
        -- Go to previous item in Trouble list
        { "[t",         function() require("trouble").prev({ mode = "diagnostics", skip_groups = true, jump = true }) end, desc = "Previous Trouble Item" },
    },
    opts = { -- Use opts for simple configuration
        position = "bottom", -- Position the Trouble window at the bottom
        height = 10, -- Set height
        fold_open = "", -- Icon for open folds
        fold_closed = "", -- Icon for closed folds
        group = true, -- Group diagnostics by severity
        padding = true, -- Add padding around the window
        action_keys = { -- Configure actions within Trouble window
            close = "q",
            cancel = "<esc>",
            refresh = "r",
            jump = { "<cr>", "<tab>" },
            open_split = { "<c-s>" },
            open_vsplit = { "<c-v>" },
            open_tab = { "<c-t>" },
            jump_close = { "o" },
            toggle_mode = "m",
            toggle_preview = "P",
            hover = "K",
            preview = "p",
            close_folds = { "zM", "zm" },
            open_folds = { "zR", "zr" },
            toggle_fold = { "zA", "za" },
            previous = "k",
            next = "j"
        },
        indent_lines = true,               -- Show indentation lines
        auto_open = false,                 -- Don't automatically open Trouble
        auto_close = false,                -- Don't automatically close Trouble
        auto_preview = true,               -- Automatically show preview when navigating
        auto_fold = false,                 -- Don't automatically fold results
        auto_jump = { "lsp_definitions" }, -- Automatically jump inside Trouble on specific actions
        signs = {
            -- Configure diagnostic signs within Trouble
            error = "",
            warning = "",
            hint = "󰌵",
            information = "",
            other = "󰠠 ",
        },
        use_diagnostic_signs = true, -- Use Neovim's diagnostic signs in the sign column
        win = {
            wo = {
                wrap = true,
            },
        },
    }
}
