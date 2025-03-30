-- lua/flaviosiqueira/plugins/09-fugitive.lua
-- Git integration using Fugitive and custom Telescope picker for branches
return {
    "tpope/vim-fugitive",
    cmd = "Git", -- Load when Git command is used
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function ()
        -- Custom Telescope branch picker logic
        local pickers = require("telescope.pickers")
        local entry_display = require("telescope.pickers.entry_display")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local utils = require("telescope.utils")
        local strings = require("plenary.strings")
        local Path = require("plenary.path")

        -- Function to read git branches
        local read_branches = function ()
            -- Check if in a git repository
            local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
            if git_dir == "" then
                vim.notify("Not a git repository.", vim.log.levels.WARN)
                return {}
            end

            local cmd = "git --no-pager branch --no-color --all"
            local handle = io.popen(cmd)
            if not handle then
                vim.notify("Error running git branch", vim.log.levels.ERROR)
                return {}
            end

            local git_branches_raw = handle:read("*a")
            handle:close()

            if not git_branches_raw or git_branches_raw == "" then
                vim.notify("No git branches found or error reading output.", vim.log.levels.WARN)
                return {}
            end

            -- Clean and parse branch names
            local cleaned_branches = git_branches_raw
                :gsub("%* ", "") -- Remove current branch indicator '*'
                :gsub("%s*remotes/origin/HEAD -> [^\n]+", "") -- Remove 'origin/HEAD -> ...'
                :gsub("%s+$", "") -- Trim trailing whitespace

            local branches = {}
            for branch in cleaned_branches:gmatch("[^\n]+") do
                local trimmed_branch = branch:gsub("^%s+", "") -- Trim leading whitespace
                if trimmed_branch ~= "" then
                    table.insert(branches, trimmed_branch)
                end
            end
            return branches
        end

        -- Function to create display entries for Telescope
        local make_branch_entry = function(opts)
            opts = opts or {}
            local icon, hl_group = utils.get_devicons("git", "GitSignsCurrentLineBlame", opts.disable_devicons)
            local icon_width = icon and strings.strdisplaywidth(icon) or 0

            local displayer = entry_display.create({
                separator = " ",
                items = {
                    { width = icon_width },
                    { remaining = true },
                },
            })

            return function(entry)
                return {
                    value = entry,
                    ordinal = entry,
                    display = function(inner_entry)
                        local display_items = {}
                        if icon then table.insert(display_items, { icon, hl_group }) end
                        table.insert(display_items, { inner_entry.value, "TelescopeResultsIdentifier" })
                        return displayer(display_items)
                    end,
                }
            end
        end

        -- The branch picker function using Telescope
        local branch_picker = function (opts)
            opts = opts or {}
            local branches_data = read_branches()
            if not branches_data or #branches_data == 0 then return end

            pickers.new(opts, {
                prompt_title = "Git Branches",
                finder = finders.new_table {
                    results = branches_data,
                    entry_maker = make_branch_entry(opts),
                },
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        if selection and selection.value and selection.value ~= "" then
                            -- Extract branch name, removing remote prefix if present
                            local branch_name = selection.value:gsub("^remotes/origin/", "")
                            vim.notify("Switching to branch: " .. branch_name, vim.log.levels.INFO)
                            -- Use Fugitive's switch command
                            vim.cmd("silent Git switch --guess " .. vim.fn.shellescape(branch_name))
                        end
                    end)
                    return true
                end,
            }):find()
        end

        -- Keybindings for Fugitive
        vim.keymap.set("n", "<leader>gs", function() vim.cmd.Git("status") end, { desc = "Git Status" })
        vim.keymap.set("n", "<leader>gd", function() vim.cmd.Git("diff HEAD") end, { desc = "Git Diff HEAD" })
        vim.keymap.set("n", "<leader>gb", function() branch_picker(require("telescope.themes").get_dropdown({})) end, { desc = "Git Branches (Pick)" }) -- Use the picker
        vim.keymap.set("n", "<leader>ga", function() vim.cmd.Git("add " .. vim.fn.expand("%")) end, { desc = "Git Add Current File" })
        vim.keymap.set("n", "<leader>gA", function() vim.cmd.Git("add .") end, { desc = "Git Add All" })
        vim.keymap.set("n", "<leader>gc", function() vim.cmd.Git("commit -v") end, { desc = "Git Commit" })
        vim.keymap.set("n", "<leader>gp", function() vim.cmd.Git("push") end, { desc = "Git Push" })
        vim.keymap.set("n", "<leader>gl", function() vim.cmd.Git("pull --rebase --autostash") end, { desc = "Git Pull Rebase" })
        vim.keymap.set("n", "<leader>gr", function() vim.cmd.Git("rebase -i " .. vim.fn.input("Rebase from: ", "main")) end, { desc = "Git Rebase Interactive" })
        vim.keymap.set("n", "<leader>gco", function() vim.cmd.Git("checkout " .. vim.fn.input("Checkout: ")) end, { desc = "Git Checkout" })
        vim.keymap.set("n", "<leader>gbl", function() vim.cmd.Git("blame") end, { desc = "Git Blame" })
        vim.keymap.set("n", "<leader>gg", function() vim.cmd.Git() end, { desc = "Git Command Window" })

    end -- End config function
}
