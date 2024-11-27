local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("telescope.utils")
local strings = require("plenary.strings")

local read_branchs = function ()
    local cmd = "git --no-pager branch --no-color --all"

    local cmd_output = os.execute(cmd .. " > /dev/null 2>&1")
    if cmd_output ~= 0 then
        return {}
    end

    local handle = io.popen(cmd)
    if handle then
        local git_branches = handle:read("*a")
        handle:close()

        if git_branches and git_branches ~= "" then
            local result = git_branches:gsub(  -- remove origin/HEAD
                "%s*remotes/origin/HEAD --> [^\n]*",
                ""
            ):gsub(  -- remove *
                "%* ",
                ""
            ):gsub(  -- remove spaces
                "[ \t\f\v\r]*",
                ""
            )
            local table_result = {}
            result:gsub("([%a%d%p]+)", function (c)
                table.insert(table_result, c)
            end)
            return table_result
        else
            vim.notify("Git branch output is nil", vim.log.levels.ERROR)
        end
    else
        vim.notify("Error running git branch", vim.log.levels.ERROR)
    end
    return {}
end

local make_branch_entry = function(opts)
    local icon_width = 0
    local icon, _ = utils.get_devicons("git", opts.disable_devicons)

    if icon then
        icon_width = strings.strdisplaywidth(icon)
    end

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = icon_width },
            { remaining = true },
        },
    })

    local make_displayer = function(entry)
        return displayer({
            icon,
            { entry.value, "TelescopeResultsIdentifier" },
        })
    end

    return function(entry)
        return {
            display = make_displayer,
            value = entry,
            ordinal = entry,
        }
    end
end


local branch_picker = function (opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Git Branches",
        finder = finders.new_table {
            results = read_branchs(),
            entry_maker = make_branch_entry(opts),
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection
                    and selection.value
                    and selection.value ~= nil
                    and selection.value ~= "" then
                    local branch = selection.value:gsub("remotes/origin/", "")
                    vim.cmd("silent Git switch -m --guess " .. branch)
                end
            end)
            return true
        end,
    }):find()
end

return {
    "tpope/vim-fugitive",

    config = function ()
        vim.keymap.set("n", "<leader>gst", function ()
            vim.cmd.Git("status")
        end)
        vim.keymap.set("n", "<leader>gdf", function ()
            vim.cmd.Git("diff HEAD")
        end)
        vim.keymap.set("n", "<leader>gss", function ()
            local opts = require("telescope.config").config
            branch_picker(opts)
        end)
        vim.keymap.set("n", "<leader>a", function ()
            vim.cmd.Git("add %")
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

