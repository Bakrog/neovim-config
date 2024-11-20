return {
    "tpope/vim-fugitive",

    config = function ()
        vim.keymap.set("n", "<leader>gs", function ()
            vim.cmd.Git("status")
        end)
        vim.keymap.set("n", "<leader>gdf", function ()
            vim.cmd.Git("diff")
        end)
        vim.keymap.set("n", "<leader>gc", function ()
            vim.cmd.Git("commit -a -m \"" .. vim.fn.input("Commit message: ") .. "\"")
        end)
        vim.keymap.set("n", "<leader>gps", function ()
            vim.cmd.Git("push")
        end)
        vim.keymap.set("n", "<leader>gpl", function ()
            vim.cmd.Git("pull --rebase --autostash")
        end)
    end
}

