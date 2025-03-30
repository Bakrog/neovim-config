-- lua/flaviosiqueira/plugins/06-telescope.lua
-- Fuzzy finder configuration
local file_ignore_patterns = {
    "yarn%.lock",
    "node_modules/",
    "raycast/",
    "dist/",
    "%.next",
    "%.git/",
    "%.gitlab/",
    "build/",
    "target/",
    "package%-lock%.json",
    "lazy%-lock%.json",
    "zig-cache/",
    "zig-out/",
}

return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8", -- Pin to a specific version for stability
    cmd = "Telescope", -- Load when Telescope command is used
    dependencies = {
        { "nvim-lua/plenary.nvim" }, -- Core dependency
        { -- Native FZF sorter for performance
            "nvim-telescope/telescope-fzf-native.nvim",
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        { "nvim-telescope/telescope-ui-select.nvim" }, -- UI enhancements
        { "nvim-tree/nvim-web-devicons" }, -- Icons in Telescope results
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                path_display = { "truncate" }, -- Shorten long paths
                layout_strategy = "horizontal", -- Default layout
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55, -- Adjust preview width
                    },
                    vertical = {
                        mirror = false,
                    },
                    flex = {
                        flip_columns = 120,
                    }
                },
                sorting_strategy = "ascending",
                winblend = 0, -- No transparency for Telescope window
                border = {},
                borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }, -- Rounded borders
                color_devicons = true,
                use_less = true, -- Use less for previewing potentially large files
                set_env = { ["COLORTERM"] = "truecolor" }, -- Ensure correct colors
                file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
                -- Default mappings
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<esc>"] = actions.close,
                        ["<CR>"] = actions.select_default,
                    },
                    n = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<esc>"] = actions.close,
                        ["<CR>"] = actions.select_default,
                    },
                },
                -- File ignore patterns defined above
                file_ignore_patterns = file_ignore_patterns,
            },
            pickers = {
                -- Configure specific pickers
                find_files = {
                    theme = "dropdown",
                    hidden = true, -- Show hidden files
                    find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                },
                git_files = {
                    theme = "dropdown",
                    hidden = true,
                    show_untracked = true,
                },
                live_grep = {
                    theme = "dropdown",
                    -- Use ripgrep for searching
                     grep_open_files = false,
                },
                grep_string = {
                    theme = "dropdown",
                },
                buffers = {
                    theme = "dropdown",
                    sort_mru = true,
                    ignore_current_buffer = true,
                },
                lsp_references = { theme = "dropdown" },
                lsp_definitions = { theme = "dropdown" },
                lsp_declarations = { theme = "dropdown" },
                lsp_implementations = { theme = "dropdown" },
                diagnostics = { theme = "dropdown" },
                -- Add more picker configurations as needed
            },
            extensions = {
                fzf = {
                    fuzzy = true,                   -- Enable fuzzy matching
                    override_generic_sorter = true, -- Use fzf sorter
                    override_file_sorter = true,    -- Use fzf file sorter
                    case_mode = "smart_case",       -- Default case sensitivity
                },
                ["ui-select"] = {
                    -- Use the default dropdown theme for ui-select
                    require("telescope.themes").get_dropdown({})
                },
                -- Configure other extensions like 'media_files' if installed
            },
        })

        -- Load installed extensions
        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "ui-select")
        -- pcall(telescope.load_extension, "media_files")

        -- Define keybindings
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", function() builtin.find_files({ hidden = true }) end, { desc = "Find Files (Hidden)" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
        vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find Old Files" })
        vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy Find in Buffer" })
        vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Find Git Files" }) -- Original keymap kept
        vim.keymap.set("n", "<leader>fs", function() builtin.find_files({ hidden = true, no_ignore = true }) end, { desc = "Find Files (Sys)" }) -- Original keymap slightly modified
        vim.keymap.set("n", "<leader>ps", function() builtin.grep_string({ search = vim.fn.input("Grep For > ") }) end, { desc = "Grep String" }) -- Original keymap kept
        vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "Resume Last Telescope" })

    end
}
