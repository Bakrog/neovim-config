return {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    config = function()
        local trouble = require("trouble")
        trouble.setup({
            win = {
                wo = {
                    wrap = true,
                },
            },
        })

        vim.keymap.set("n", "<leader>tt", function()
            trouble.toggle("diagnostics")
        end)

        vim.keymap.set("n", "tp", function()
            trouble.prev("diagnostics")
            trouble.jump("diagnostics")
        end)

        vim.keymap.set("n", "tn", function()
            trouble.next("diagnostics")
            trouble.jump("diagnostics")
        end)
    end
}
