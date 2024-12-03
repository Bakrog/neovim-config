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
        "pipoprods/nvm.nvim",
    },
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("neotest").setup({
            ---@diagnostic disable-next-line: missing-fields
            discovery = {
                enabled = false,
            },
            adapters = {
                --require("neotest-plenary").setup({}),
                require("neotest-python")({
                    dap = {
                        justMyCode = true,
                    },
                    pytest_discover_instances = true,
                }),
                require("neotest-jest")({
                    jestCommand = "yarn test",
                    jestConfigFile = function ()
                       return vim.fn.getcwd() .. "/jest.config.js"
                    end,
                    jest_test_discovery = true,
                    cwd = function()
                        return vim.fn.getcwd()
                    end,
                }),
                require("neotest-elixir"),
                require("neotest-rust"),
            }
        })

        vim.keymap.set("n", "<leader>tc", function()
            local neotest = require("neotest")
            neotest.output_panel.clear()
            neotest.run.run()
        end)

        vim.keymap.set("n", "<leader>tf", function()
            local neotest = require("neotest")
            neotest.output_panel.clear()
            neotest.run.run(vim.fn.expand("%"))
        end)

        vim.keymap.set("n", "<leader>tT", function()
            local neotest = require("neotest")
            neotest.output_panel.clear()
            neotest.run.run(vim.uv.cwd())
        end)

        vim.keymap.set("n", "<leader>ts", function ()
            local neotest = require("neotest")
            neotest.summary.toggle()
            neotest.output_panel.toggle()
        end)

        vim.keymap.set("n", "<leader>dt", function()
            local neotest = require("neotest")
            ---@diagnostic disable-next-line: missing-fields 
            neotest.run.run({ strategy = "dap" })
        end)

        vim.keymap.set("n", "T", function()
            local neotest = require("neotest")
            neotest.output.open({ enter = true, auto_close = true })
        end)
    end,
}

