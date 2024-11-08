return {
    "coffebar/neovim-project",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope.nvim", tag = "0.1.8" },
        { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 100,
    init = function()
        -- enable saving the state of plugins in the session
        vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    end,

    config = function ()
        require("neovim-project").setup {
            projects = {
            },
            picker = {
                type = "telescope",
            }
        }

        local M = require("neovim-project.project")
        local picker = require("neovim-project.picker")

        vim.keymap.set("n", "<leader>pp", function(args)
            picker.create_picker(args, true, M.switch_project)
        end, { noremap = true, silent = true })
    end
}

