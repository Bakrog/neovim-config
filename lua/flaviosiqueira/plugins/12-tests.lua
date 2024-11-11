return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-plenary",
        "nvim-neotest/neotest-python",
        "nvim-neotest/neotest-jest",
        "jfpedroza/neotest-elixir",
        "rouge8/neotest-rust",
    },
    config = function()
        local neotest = require("neotest")
        neotest.setup({
            adapters = {
                require("neotest-plenary").setup({
                    -- this is my standard location for minimal vim rc
                    -- in all my projects
                    min_init = "./scripts/tests/minimal.vim",
                }),
                require("neotest-python"),
                require("neotest-jest")({
                    jestCommand = "npm test --",
                    jestConfigFile = "custom.jest.config.ts",
                    env = { CI = true },
                    cwd = function()
                        return vim.fn.getcwd()
                    end,
                }),
                require("neotest-elixir"),
                require("neotest-rust"),
            }
        })

        vim.keymap.set("n", "<leader>tc", function()
            neotest.output_panel.clear()
            neotest.run.run()
        end)

        vim.keymap.set("n", "<leader>tf", function()
            neotest.output_panel.clear()
            neotest.run.run(vim.fn.expand("%"))
        end)

        vim.keymap.set("n", "<leader>ts", function ()
            neotest.summary.toggle()
            neotest.output_panel.toggle()
        end)
    end,
}

