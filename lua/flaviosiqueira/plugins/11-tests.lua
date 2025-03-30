-- lua/flaviosiqueira/plugins/11-tests.lua
-- Test runner integration using Neotest
return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim", -- Recommended dependency
        "nvim-treesitter/nvim-treesitter", -- Required for test discovery
        "nvim-neotest/nvim-nio",           -- Required dependency

        -- Language/Framework Adapters
        "nvim-neotest/neotest-plenary",                    -- For testing Lua plugins
        "nvim-neotest/neotest-python",                     -- Python (pytest, unittest)
        "haydenmeade/neotest-jest",                        -- Jest (JavaScript/TypeScript)
        "jfpedroza/neotest-elixir",                        -- Elixir (ExUnit)
        { "lawrence-laz/neotest-zig", version = "1.3.*" }, -- Zig tests
        "marilari88/neotest-vitest",                       -- Vitest (JavaScript/TypeScript)
        "mrcjkb/rustaceanvim",                             -- Integrates Neotest for Rust

        -- Optional: DAP integration for debugging tests
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
    },
    keys = {
        -- Run tests for the nearest context (function, class, file)
        {
            "<leader>tn",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                neotest.run.run()
            end,
            desc = "Run Nearest Test"
        },
        -- Run all tests in the current file
        {
            "<leader>tf",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                neotest.run.run(vim.fn.expand("%"))
            end,
            desc = "Run File Tests"
        },
        -- Run all tests in the current directory/project
        {
            "<leader>tT",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                neotest.run.run(vim.uv.cwd())
            end,
            desc = "Run All Tests (Dir)"
        },
        -- Debug the nearest test
        {
            "<leader>td",
            function()
                local neotest = require("neotest")
                neotest.output_panel.clear()
                neotest.summary.clear_marked()
                ---@diagnostic disable-next-line: missing-fields
                neotest.run.run({ suite = false, strategy = "dap" })
                --require("neotest").run.run({ strategy = "dap" })
            end,
            desc = "Debug Nearest Test"
        },
        -- Stop the current test run
        {
            "<leader>tk",
            function()
                require("neotest").run.stop()
            end,
            desc = "Stop Test Run"
        },
        -- Toggle the test summary window
        {
            "<leader>ts",
            function()
                local neotest = require("neotest")
                neotest.summary.toggle()
                neotest.output_panel.toggle()
            end,
            desc = "Toggle Test Summary"
        },
        -- Show test output for the nearest test
        {
            "T",
            function()
                require("neotest").output.open({ enter = true })
            end,
            desc = "Show Test Output"
        },
        -- Jump to the next test position
        { "]n", function() require("neotest").jump.next() end, desc = "Next Test Position" },
        -- Jump to the previous test position
        { "[n", function() require("neotest").jump.prev() end, desc = "Previous Test Position" },
    },
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("neotest").setup({
            -- Enable asynchronous test discovery
            discovery = {
                enabled = true,
                -- concurrent = 0, -- Set a number > 0 for concurrent discovery (experimental)
            },
            -- log_level = vim.log.levels.DEBUG, -- Uncomment for debugging
            -- Status signs in the sign column
            status = { enabled = true, virtual_text = true },
            signs = {
                -- Customize signs used by Neotest
                passed = { text = "✓", hl = "NeotestPassed" },
                failed = { text = "✗", hl = "NeotestFailed" },
                skipped = { text = "»", hl = "NeotestSkipped" },
                running = { text = "", hl = "NeotestRunning" },
                unknown = { text = "?", hl = "NeotestUnknown" },
            },
            -- Configure the output panel
            output = {
                enabled = true,
                open_on_run = false, -- Don't automatically open output panel
                follow = true,       -- Follow output as tests run
            },
            -- Configure the summary window
            summary = {
                enabled = true,
                open_on_run = "failed", -- Open summary only if tests fail
                follow = true,
                mappings = {
                    attach = "<leader>ta",
                    clear_marked = "mc",
                    clear_passed = "mP",
                    clear_failed = "mF",
                    debug = "<leader>td",
                    expand = "zo",
                    expand_all = "zO",
                    jumpto = "<CR>",
                    mark = "m",
                    output = "o",
                    run = "<leader>tn",
                    short = "OS",
                    stop = "<leader>tk",
                    toggle_marked = "mt",
                    watch = "<leader>tw",
                }
            },
            -- Configure test adapters
            adapters = {
                require("neotest-plenary").setup({}),
                require("neotest-python")({
                    -- Specify the DAP configuration name for debugging Python tests
                    dap = {
                        adapter = "python", -- Matches the name in nvim-dap config
                        configuration = function(root, config)
                            -- Ensure the configuration matches your nvim-dap setup
                            return vim.tbl_deep_extend("force", config, {
                                name = "Neotest Python Debug",
                                type = "python",
                                request = "launch",
                                module = "pytest", -- Or "unittest" if using unittest adapter
                                console = "integratedTerminal",
                                justMyCode = true,
                                args = config.args -- Pass args from neotest
                                -- Add other DAP config options if needed
                            })
                        end,
                        justMyCode = true, -- Common DAP setting
                    },
                    -- runner = "pytest", -- Explicitly set runner if needed
                    pytest_discover_instances = false, -- Disable instance discovery if causing issues
                }),
                require("neotest-vitest"),
                require("neotest-jest")({
                    -- Use yarn test command prefix
                    jestCommand = "yarn test --",
                    -- Function to find Jest config file
                    jestConfigFile = function(file_path)
                        return require("neotest.providers.jest.config").find_config(file_path,
                            { 'jest.config.js', 'jest.config.ts', 'jest.config.mjs', 'jest.config.cjs' })
                        -- or return custom path: return vim.fn.getcwd() .. "/jest.config.js"
                    end,
                    -- Disable Jest's internal test discovery if Neotest handles it better
                    -- jest_test_discovery = false,
                    -- env = { CI = true }, -- Pass environment variables if needed
                    cwd = function() return vim.uv.cwd() end, -- Set CWD for Jest
                }),
                require("neotest-elixir"),
                require("rustaceanvim.neotest"),
                require("neotest-zig").setup({
                    -- Zig specific options
                    -- dap = { adapter = "codelldb" } -- Example DAP config
                }),
            } -- End adapters table
        })    -- End neotest.setup
    end,      -- End config function
}
