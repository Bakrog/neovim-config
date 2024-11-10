local function load_projects_locations()
    local file = io.open(vim.fn.stdpath("config") .. "lua/flaviosiqueira/plugins/11-projects.json", "r")
    if not file then
        return {}

    end
    local jsonString = file:read("*all")
    return vim.json.decode(jsonString)
end

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
        --local projects = load_projects_locations()
        --print(vim.inspect(projects))

        require("neovim-project").setup {
            projects = load_projects_locations(),
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

