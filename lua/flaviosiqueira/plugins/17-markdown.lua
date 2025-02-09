return {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = vim.fn.stdpath("data") .. "/mason/bin/deno task --quiet build:fast",
    keys = {
        { "n", "<leader>mko", "<cmd>PeekOpen<CR>" },
        { "n", "<leader>mkc", "<cmd>PeekClose<CR>" },
        { "n", "n", "nzzzv" }, -- Small hack because peek overrides search keyword
    },
    config = function()
        require("peek").setup()
        vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
        vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
}

