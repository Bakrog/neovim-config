local function load_projects_locations()
    local file = io.open(vim.fn.stdpath("config") .. "/lua/flaviosiqueira/plugins/11-projects.json", "r")
    if not file then
        return {}

    end
    local jsonString = string.gsub(file:read("*all"), "//[^,\n]*,\n", "")
    file:close()
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
        local config = require('session_manager.config')
        require("neovim-project").setup {
            projects = load_projects_locations(),
            picker = {
                type = "telescope",
            },
            last_session_on_startup = false,
            dashboard_mode = true,
            -- Overwrite some of Session Manager options
            session_manager_opts = {
                autoload_mode = config.AutoloadMode.Disabled,
                autosave_only_in_session = true,
                autosave_ignore_dirs = {
                    vim.fn.expand("~"), -- don't create a session for $HOME/
                    "/tmp",
                },
                autosave_ignore_filetypes = {
                    -- All buffers of these file types will be closed before the session is saved
                    "ccc-ui",
                    "gitcommit",
                    "gitrebase",
                    "qf",
                    "toggleterm",
                },
            },
        }

        vim.keymap.set("n", "<leader>pp", function(args)
            local M = require("neovim-project.project")
            local picker = require("neovim-project.picker")
            picker.create_picker(args, true, M.switch_project)
        end, { noremap = true, silent = true })
    end
}

