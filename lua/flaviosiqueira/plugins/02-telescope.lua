return {
    "nvim-telescope/telescope.nvim", tag = "0.1.8",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
        {
            "nvim-tree/nvim-web-devicons",
            enabled = vim.g.have_nerd_fonts,
        },
    },

    config = function()
        require("telescope").setup {
            extensions = {
                fzf = {
                    fuzzy = true,                    -- false will only do exact matching
                    override_generic_sorter = true,  -- override the generic sorter
                    override_file_sorter = true,     -- override the file sorter
                    case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                },
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {

                    }
                },
            }
        }

        require('telescope').load_extension('fzf')
        require("telescope").load_extension("ui-select")

        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>fs", builtin.find_files, {
            desc = "Files search"
        })
        vim.keymap.set("n", "<leader>gf", builtin.git_files, {
            desc = "Git files search",
        })
        vim.keymap.set("n", "<leader>ps", function()
            builtin.grep_string({ search = vim.fn.input("> ") })
        end,
            {
                desc = "Project search"
            })

    end
}

