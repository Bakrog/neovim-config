return {
    "tpope/vim-fugitive",

    config = function ()
        vim.keymap.set("n", "<leader>gs", function ()
            local git_command = vim.fn.input("> ")
            vim.cmd.Git(git_command)
        end)
    end
}

