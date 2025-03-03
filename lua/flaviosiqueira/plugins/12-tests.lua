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
        --"mrcjkb/rustaceanvim",
        {
            "lawrence-laz/neotest-zig",
            version = "1.3.*",
        },
        "marilari88/neotest-vitest",
    },
    keys = {
        {
            "<leader>tc",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                neotest.run.run()
            end
        },
        {
            "<leader>tf",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                neotest.run.run(vim.fn.expand("%"))
            end
        },
        {
            "<leader>tT",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                neotest.run.run(vim.uv.cwd())
            end
        },
        {
            "<leader>ts",
            function()
                local neotest = require("neotest")
                neotest.summary.toggle()
                neotest.output_panel.toggle()
            end
        },
        {
            "<leader>td",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                ---@diagnostic disable-next-line: missing-fields
                neotest.run.run({ suite = false, strategy = "dap" })
            end
        },
        {
            "T",
            function()
                local neotest = require("neotest")
                neotest.output.open({ enter = true, auto_close = true })
            end
        },
    },
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("neotest").setup({
            ---@diagnostic disable-next-line: missing-fields
            discovery = {
                enabled = false,
            },
            --log_level = vim.log.levels.TRACE,
            adapters = {
                require("neotest-plenary").setup({}),
                require("neotest-python")({
                    dap = {
                        justMyCode = true,
                    },
                    pytest_discover_instances = false,
                }),
                require("neotest-vitest"),
                require("neotest-jest")({
                    jestCommand = "yarn test --",
                    jestConfigFile = function()
                        return vim.fn.getcwd() .. "/jest.config.js"
                    end,
                    jest_test_discovery = false,
                    --env = { CI = true },
                    cwd = function()
                        return vim.fn.getcwd()
                    end,
                }),
                require("neotest-elixir"),
                require("neotest-rust")({
                    args = { "--no-capture" },
                    dap_adapter = "codelldb",
                }),
                --require('rustaceanvim.neotest'),
                require("neotest-zig")({
                    --dap = {
                    --    adapter = "codelldb",
                    --}
                }),
            }
        })
    end,
}
