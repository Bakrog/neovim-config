-- lua/flaviosiqueira/plugins/13-debug.lua
-- Debug Adapter Protocol (DAP) setup for debugging
return {
    {
        "mfussenegger/nvim-dap",
        -- Load DAP lazily on specific keys or commands
        keys = {
            { "<leader>db", desc = "DAP: Toggle Breakpoint" },
            { "<leader>dc", desc = "DAP: Continue" },
            { "<leader>di", desc = "DAP: Step Into" },
            { "<leader>do", desc = "DAP: Step Out" },
            { "<leader>dj", desc = "DAP: Step Over" },
            { "<leader>dr", desc = "DAP: Restart" },
            { "<leader>ds", desc = "DAP: Stop" },
            { "<leader>dl", desc = "DAP: Run Last" },
            { "<leader>dC", desc = "DAP: Set Conditional Breakpoint" },
            { "<leader>dU", desc = "DAP: Go To UI" },
        },
        dependencies = {
            -- Virtual text for inline debugging info (optional but nice)
            { "theHamsta/nvim-dap-virtual-text", opts = {} },

            -- UI for DAP (scopes, breakpoints, console, etc.)
            {
                "rcarriga/nvim-dap-ui",
                keys = { { "<leader>dU", function() require("dapui").toggle({}) end, desc = "Toggle DAP UI" } },
                dependencies = { "nvim-neotest/nvim-nio" }, -- Required dependency for dapui
                opts = {
                    layouts = {
                        {
                            elements = {
                                { id = "scopes",      size = 0.25 },
                                { id = "breakpoints", size = 0.25 },
                                { id = "stacks",      size = 0.25 },
                                { id = "watches",     size = 0.25 },
                            },
                            size = 40, -- Width of the side layout
                            position = "left",
                        },
                        {
                            elements = {
                                { id = "repl",    size = 0.5 },
                                { id = "console", size = 0.5 },
                            },
                            size = 0.25, -- Height of the bottom layout
                            position = "bottom",
                        },
                    },
                    floating = {
                        max_height = nil, -- Use default
                        max_width = nil,  -- Use default
                        border = "rounded",
                        mappings = {
                            close = { "q", "<Esc>" },
                        },
                    },
                    windows = { indent = 1 },
                    render = {                 -- Render configuration (optional)
                        max_type_length = nil, -- Don't truncate type names
                        max_value_lines = 100, -- Increase max lines shown for values
                    }
                },
                config = function(_, opts)
                    local dap, dapui = require("dap"), require("dapui")
                    dapui.setup(opts)

                    -- Open DAP UI automatically on debug events
                    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
                    -- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
                    -- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end
                end,
            },

            -- Python debugging support
            {
                "mfussenegger/nvim-dap-python",
                ft = "python",                          -- Load specifically for Python files
                dependencies = "mfussenegger/nvim-dap", -- Ensure dap loads first
                config = function()
                    -- Find python executable, preferring virtual environments
                    local function get_python_path(cwd)
                        cwd = cwd or vim.fn.getcwd()
                        local venv_path = cwd .. '/.venv/bin/python'
                        local venv_path_alt = cwd .. '/venv/bin/python'
                        if vim.fn.executable(venv_path) == 1 then
                            return venv_path
                        elseif vim.fn.executable(venv_path_alt) == 1 then
                            return venv_path_alt
                        else
                            -- Fallback: Try finding python3 in PATH
                            local python3 = vim.fn.exepath('python3')
                            if python3 ~= "" then return python3 end
                            -- Last resort: Hardcoded path (adjust if needed)
                            return '/usr/bin/python'
                        end
                    end

                    -- Setup dap-python using the located python path
                    -- The path passed to setup is used to find the debugpy adapter
                    local python_for_debugpy = get_python_path()
                    require("dap-python").setup(python_for_debugpy)

                    -- Add Python DAP configurations
                    require('dap').configurations.python = {
                        {
                            type = 'python', -- Use the adapter name defined by dap-python
                            request = 'launch',
                            name = "Launch file",
                            program = "${file}",
                            pythonPath = function() -- Use the resolved path for the *program* execution
                                return get_python_path()
                            end,
                            justMyCode = true,
                            console = "integratedTerminal", -- Or "internalConsole"
                        },
                        {
                            type = 'python',
                            request = 'attach',
                            name = "Attach to process",
                            connect = {
                                host = "127.0.0.1",
                                port = 5678 -- Default debugpy port
                            },
                            pathMappings = {
                                { localRoot = "${workspaceFolder}", remoteRoot = "." }
                            },
                            justMyCode = true,
                        }
                        -- Add configurations for Django, Flask, etc. if needed
                    }
                end,
            }
            -- Add dependencies for other languages (e.g., Java, Go, Node) if needed
        },
        config = function()
            local dap = require("dap")
            dap.set_log_level("DEBUG") -- Uncomment for debugging DAP itself

            -- Define DAP adapters using paths from mason-tool-installer
            local mason_path = vim.fn.stdpath("data") .. "/mason"

            -- Node.js / JavaScript / TypeScript (using js-debug-adapter)
            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}", -- DAP will find a free port
                executable = {
                    command = mason_path .. "/bin/js-debug-adapter",
                    args = { "${port}" },
                },
            }
            dap.configurations.javascript = { -- Applies to TS as well
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    runtimeExecutable = "node", -- Ensure node is in PATH
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach to process",
                    processId = require 'dap.utils'.pick_process, -- Helper to pick process
                    cwd = "${workspaceFolder}",
                },
                -- Add Jest config if debugging tests via DAP directly
                -- {
                --     type = "pwa-node",
                --     request = "launch",
                --     name = "Debug Jest Tests",
                --     runtimeExecutable = "node",
                --     runtimeArgs = {
                --         "${workspaceFolder}/node_modules/.bin/jest",
                --         "--runInBand",
                --         "--watchAll=false"
                --     },
                --     rootPath = "${workspaceFolder}",
                --     cwd = "${workspaceFolder}",
                --     console = "integratedTerminal",
                --     internalConsoleOptions = "neverOpen",
                -- }
            }
            dap.configurations.typescript = dap.configurations.javascript -- Reuse JS config

            -- C/C++/Rust/Zig (using codelldb)
            local codelldb_path = mason_path .. "/packages/codelldb/codelldb"
            local liblldb_path = mason_path ..
                "/packages/codelldb/extension/lldb/lib/liblldb.dylib" -- Adjust for OS (.so for Linux)

            if vim.fn.executable(codelldb_path) == 1 then
                -- dap.adapters.codelldb = {
                --     type = "server",
                --     port = "${port}", -- Will find a free port
                --     executable = {
                --         command = codelldb_path,
                --         args = { "--port", "${port}", "--liblldb", liblldb_path },
                --         -- HACK: Workaround for adapter failing to start on some systems
                --         --   If you see 'Cannot connect to DAP server' errors, uncomment below
                --         -- detached = false,
                --     }
                -- }
                -- Basic C/C++ config (requires manual build with debug symbols)
                dap.configurations.cpp = {
                    {
                        name = "Launch file",
                        type = "lldb",
                        request = "launch",
                        program = function()
                            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                        end,
                        cwd = '${workspaceFolder}',
                        stopOnEntry = false,
                        terminal = "integrated", -- Or "external"
                    },
                }
                dap.configurations.c = dap.configurations.cpp -- Reuse C++ config

                -- Rust configuration (delegated to rustaceanvim)
                -- dap.configurations.rust = { ... } -- See rustaceanvim config

                -- Zig configuration
                dap.configurations.zig = {
                    {
                        name = "Launch file (Zig)",
                        type = "lldb",
                        request = "launch",
                        program = function()
                            -- Assumes executable is in ./zig-out/bin/
                            local root = require("lspconfig.util").root_pattern("build.zig", ".git")(vim.api
                                .nvim_buf_get_name(0))
                            local exe_name = vim.fs.basename(root)
                            local default_path = root .. "/zig-out/bin/" .. exe_name
                            return vim.fn.input('Path to Zig executable: ', default_path, 'file')
                        end,
                        cwd = '${workspaceFolder}',
                        stopOnEntry = false,
                        terminal = "integrated",
                    },
                }
            else
                vim.notify("codelldb adapter not found or not executable at: " .. codelldb_path, vim.log.levels.WARN)
            end


            -- Assign keymaps (moved from keys section for clarity)
            vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dc", require("dap").continue, { desc = "DAP: Continue" })
            vim.keymap.set("n", "<leader>di", require("dap").step_into, { desc = "DAP: Step Into" })
            vim.keymap.set("n", "<leader>do", require("dap").step_out, { desc = "DAP: Step Out" })
            vim.keymap.set("n", "<leader>dj", require("dap").step_over, { desc = "DAP: Step Over" })
            vim.keymap.set("n", "<leader>dr", require("dap").repl.toggle, { desc = "DAP: Toggle REPL" })
            vim.keymap.set("n", "<leader>ds", require("dap").terminate, { desc = "DAP: Stop" })
            vim.keymap.set("n", "<leader>dl", require("dap").run_last, { desc = "DAP: Run Last" })
            vim.keymap.set("n", "<leader>dC",
                function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
                { desc = "DAP: Set Conditional Breakpoint" })
            vim.keymap.set("n", "<leader>dW", require("dap.ui.widgets").hover, { desc = "DAP: Hover Widgets" })
            vim.keymap.set("n", "<leader>dE", require("dapui").eval, { desc = "DAP: Evaluate Expression" })
        end -- End main config function
    },      -- End nvim-dap block
}           -- End return table
