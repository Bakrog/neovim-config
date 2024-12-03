local python_path = function()
    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
    local cwd = vim.fn.getcwd()
    if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
    else
        return '/usr/local/bin/python'
    end
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require("dap")

            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>dc", dap.continue)
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function(_, opts)
            require("dapui").setup(opts)

            local dap, dapui = require("dap"), require("dapui")


            dap.adapters.python = function(cb, config)
                if config.request == 'attach' then
                    ---@diagnostic disable-next-line: undefined-field
                    local port = (config.connect or config).port
                    ---@diagnostic disable-next-line: undefined-field
                    local host = (config.connect or config).host or '127.0.0.1'
                    cb({
                        type = 'server',
                        port = assert(port, '`connect.port` is required for a python `attach` configuration'),
                        host = host,
                        options = {
                            source_filetype = 'python',
                        },
                    })
                else
                    cb({
                        type = 'executable',
                        command = 'python3',
                        args = { '-m', 'debugpy.adapter' },
                        options = {
                            source_filetype = 'python',
                        },
                    })
                end
            end

            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    pythonPath = python_path,
                    pathMappings = {
                        {
                            --localRoot = "${workspaceFolder}",
                            localRoot = vim.fn.getcwd(),
                            remoteRoot = vim.fn.getcwd(),
                        },
                    },
                    justMyCode = true,
                },
            }

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end
    },
    --{
    --    "jay-babu/mason-nvim-dap.nvim",
    --    opts = {
    --        ensure_installed = {
    --            "python",
    --        },
    --        handlers = {
    --            python = function() end,
    --        },
    --    },
    --},
    {
        "mfussenegger/nvim-dap-python",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        --config = function()
        --    --local python_location = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        --    --require("dap-python").setup(python_location)
        --    local python_location = vim.fn.getcwd() .. "/.venv/bin/python"
        --    require("dap-python").setup(python_location)
        --    require("dap-python").test_runner = "pytest"
        --end,
    },
}

