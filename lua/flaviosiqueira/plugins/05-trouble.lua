return {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    config = function()
        local trouble = require("trouble")
        trouble.setup({})

        vim.keymap.set("n", "<leader>tt", function()
            trouble.toggle("diagnostics")
        end)

        vim.keymap.set("n", "[t", function()
            trouble.prev("diagnostics")
            trouble.jump("diagnostics")
        end)

        vim.keymap.set("n", "]t", function()
            trouble.next("diagnostics")
            trouble.jump("diagnostics")
        end)
    end
}
