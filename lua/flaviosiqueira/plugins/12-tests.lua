local python_path = function()
    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
    local cwd = vim.fn.getcwd()
    print("Python path: " .. cwd)
    if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
    else
        return '/usr/local/bin/python'
    end
end

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
        require("neotest").setup({
            adapters = {
                require("neotest-plenary").setup({
                    -- this is my standard location for minimal vim rc
                    -- in all my projects
                    min_init = "./scripts/tests/minimal.vim",
                }),
                require("neotest-python")({
                    dap = {
                        justMyCode = true,
                    },
                }),
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
            local neotest = require("neotest")
            neotest.output_panel.clear()
            neotest.run.run()
        end)

        vim.keymap.set("n", "<leader>tf", function()
            local neotest = require("neotest")
            neotest.output_panel.clear()
            neotest.run.run(vim.fn.expand("%"))
        end)

        vim.keymap.set("n", "<leader>ts", function ()
            local neotest = require("neotest")
            neotest.summary.toggle()
            neotest.output_panel.toggle()
        end)

        vim.keymap.set("n", "<leader>dt", function()
            local neotest = require("neotest")
            neotest.run.run({strategy = "dap"})
        end)
    end,
}

