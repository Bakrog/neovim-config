return {
    "tpope/vim-fugitive",

    config = function ()
        vim.keymap.set("n", "<leader>gs", function ()
            vim.cmd.Git("status")
        end)
        vim.keymap.set("n", "<leader>gc", function ()
            vim.cmd.Git("commit -a -m \"" .. vim.fn.input("Commit message: ") .. "\"")
        end)
        vim.keymap.set("n", "<leader>gp", function ()
            vim.cmd.Git("push")
        end)
    end
}

