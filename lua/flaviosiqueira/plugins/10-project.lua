-- lua/flaviosiqueira/plugins/10-project.lua
-- Project management and session saving
return {
    "coffebar/neovim-project",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "Shatur/neovim-session-manager", -- Session management integration
    },
    -- Load on command or keymap
    cmd = { "NeovimProjectRoot", "NeovimProjectLoad", "NeovimProjectLoadRecent" },
    keys = {
        { "<leader>fp", desc = "Find Projects" } -- Placeholder description, mapped below
    },
    -- priority = 100, -- Usually not needed if loaded lazily
    init = function()
        -- enable saving the state of plugins in the session
        vim.opt.sessionoptions:append("globals") -- save global variables

        -- Function to safely load projects from JSON
        local function load_projects_locations()
            local projects_file = vim.fn.stdpath("config") .. "/lua/flaviosiqueira/projects.json"
            local file = io.open(projects_file, "r")
            if not file then
                vim.notify("Project file not found: " .. projects_file, vim.log.levels.WARN)
                return {}
            end
            local content = file:read("*a")
            file:close()

            -- Basic JSON cleaning (remove comments) - More robust parsing might be needed
            content = string.gsub(content, "//[^\n]*", "") -- Remove // comments
            content = string.gsub(content, "/%*.-%*/", "") -- Remove /* */ comments (simple version)

            local ok, projects = pcall(vim.json.decode, content)
            if not ok then
                vim.notify("Error decoding projects JSON: " .. projects_file .. "\n" .. tostring(projects),
                    vim.log.levels.ERROR)
                return {}
            end
            return projects
        end
        -- Store loaded projects in a global or cached variable if needed early
        -- vim.g.loaded_projects = load_projects_locations()
        _G.load_projects_locations = load_projects_locations -- Make accessible in config
    end,
    config = function()
        local config = require('session_manager.config')
        require("neovim-project").setup {
            -- Load projects using the function defined in init
            projects = _G.load_projects_locations(),
            -- Use Telescope for picking projects
            picker = {
                type = "telescope",
                -- Telescope options can be added here if needed
                telescope_opts = { theme = require("telescope.themes").get_dropdown() }
            },
            -- Don't automatically load the last session on startup
            last_session_on_startup = false,
            -- Integrate with dashboard if you use one (e.g., alpha-nvim, dashboard-nvim)
            dashboard_mode = true, -- Set to true if using a dashboard that supports it
            -- Configure Session Manager integration
            session_manager_opts = {
                -- Only autosave when explicitly in a project session managed by neovim-project
                autoload_mode = config.AutoloadMode.Disabled, -- Let neovim-project handle loading
                autosave_only_in_session = true,
                -- Define directories/paths to ignore for automatic session saving
                autosave_ignore_dirs = {
                    vim.fn.expand("~"),       -- Don't create sessions directly in HOME
                    vim.fn.stdpath("config"), -- Don't create sessions for config editing
                    "/tmp",
                },
                -- Filetypes to ignore when saving sessions (close buffers of these types)
                autosave_ignore_filetypes = {
                    "ccc-ui",
                    "gitcommit",
                    "gitrebase",
                    "qf",       -- Quickfix list
                    "Trouble",  -- Trouble window
                    "NvimTree", -- File explorer
                    "alpha",    -- Dashboard
                    "TelescopePrompt",
                    "mason",
                    "lazy",
                    "neotest-summary",
                    "neotest-output",
                },
                -- Path where sessions are stored
                sessions_dir = vim.fn.stdpath('data') .. '/sessions/',
                -- Function to determine the session filename
                session_filename_maker = function(project_root_dir)
                    local dir_name = vim.fs.basename(project_root_dir)
                    return dir_name .. '_session.vim'
                end,
            },
        }

        -- Keymap to open the project picker
        vim.keymap.set("n", "<leader>fp", function(args)
            local M = require("neovim-project.project")
            local picker = require("neovim-project.picker")
            picker.create_picker(args, true, M.switch_project)
        end, { noremap = true, silent = true, desc = "Find Projects" })
    end, -- End config function
}
