return {
    "tpope/vim-fugitive",

    config = function ()
        vim.keymap.set("n", "<leader>st", function ()
            vim.cmd.Git("status")
        end)
        vim.keymap.set("n", "<leader>sg", function ()
            vim.cmd.Git("commit -a -m \"" .. vim.fn.input("Commit message: ") .. "\"")
        end)
    end
}

