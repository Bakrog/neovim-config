local pythonPath = function()
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

local rustPath = function()
    local dap = require("dap")
    vim.fn.jobstart(
        { "cargo", "build", "-q" },
        { env = { RUST_BACKTRACE = "1", RUSTFLAGS = "-g" } }
    )
    local paths = vim.fs.find(
        { "Cargo.toml" },
        {
            path = vim.fs.dirname(vim.fn.expand("%")),
            upward = true
        }
    )
    --vim.notify(vim.inspect(paths), vim.log.levels.ERROR)
    if paths == nil or #paths == 0 then
        return dap.ABORT
    end
    local basename = vim.fs.basename(paths[1]:gsub("/Cargo.toml", ""))
    --vim.notify(basename, vim.log.levels.ERROR)
    return vim.fn.getcwd() .. "/target/debug/" .. basename
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
        },
        keys = {
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end
            },
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end
            },
            {
                "<leader>ds",
                function()
                    require("dap").terminate()
                    require("dapui").close()
                end
            },
        },
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
            dap.set_log_level("DEBUG")


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
                    pythonPath = pythonPath,
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

            dap.adapters.lldb = {
                type = "executable",
                command = "/usr/local/opt/llvm/bin/lldb-dap",
                name = "lldb",
            }

            dap.adapters.cppdbg = {
                id = "cppdbg",
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
            }

            local codelldb_location = "/mason/packages/codelldb/extension"

            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.resolve(
                        vim.fn.stdpath("data") ..
                        codelldb_location ..
                        "/adapter/codelldb"
                    ),
                    args = {
                        "--port",
                        "${port}",
                        "--liblldb",
                        vim.fn.resolve(
                            vim.fn.stdpath("data") ..
                            codelldb_location ..
                            "/lldb/lib/liblldb.dylib"
                        ),
                    },
                },
            }

            dap.configurations.rust = {
                --{
                --    name = "Launch file",
                --    type = "cppdbg",
                --    request = "launch",
                --    program = rustPath,
                --    cwd = vim.fn.getcwd,
                --    stopAtEntry = true,
                --},
                --{
                --    name = 'Attach to gdbserver :1234',
                --    type = 'cppdbg',
                --    request = 'launch',
                --    MIMode = 'gdb',
                --    miDebuggerServerAddress = 'localhost:1234',
                --    miDebuggerPath = '/usr/bin/gdb',
                --    cwd = vim.fn.getcwd,
                --    program = rustPath,
                --},
                {
                    name = "Launch file",
                    type = "lldb",  -- codelldb
                    request = "launch",
                    program = rustPath,
                    cwd = vim.fn.getcwd,
                    stopOnEntry = false,
                    terminal = "integrated",
                    showDisassembly = false,
                    initCommands = function()
                        -- Find out where to look for the pretty printer Python module
                        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

                        local script_import = 'command script import "' ..
                            rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                        local commands = {}
                        local file = io.open(commands_file, 'r')
                        if file then
                            for line in file:lines() do
                                table.insert(commands, line)
                            end
                            file:close()
                        end
                        table.insert(commands, 1, script_import)

                        return commands
                    end,
                },
                --{
                --    name = 'Launch',
                --    type = 'lldb',
                --    request = 'launch',
                --    program = rustPath,
                --    cwd = vim.fn.getcwd,
                --    stopOnEntry = false,
                --    args = {},
                --    runInTerminal = false,
                --    initCommands = function()
                --        -- Find out where to look for the pretty printer Python module
                --        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

                --        local script_import = 'command script import "' ..
                --            rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                --        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                --        local commands = {}
                --        local file = io.open(commands_file, 'r')
                --        if file then
                --            for line in file:lines() do
                --                table.insert(commands, line)
                --            end
                --            file:close()
                --        end
                --        table.insert(commands, 1, script_import)

                --        return commands
                --    end,
                --},
                --{
                --    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
                --    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                --    name = "Attach to process",
                --    type = 'lldb', -- Adjust this to match your adapter name (`dap.adapters.<name>`)
                --    request = 'attach',
                --    pid = require('dap.utils').pick_process,
                --    args = {},
                --},
            }

            dap.configurations.zig = {
                --{
                --    name = "Launch file",
                --    type = "cppdbg",
                --    request = "launch",
                --    program = rustPath,
                --    cwd = vim.fn.getcwd,
                --    stopAtEntry = true,
                --},
                --{
                --    name = 'Attach to gdbserver :1234',
                --    type = 'cppdbg',
                --    request = 'launch',
                --    MIMode = 'gdb',
                --    miDebuggerServerAddress = 'localhost:1234',
                --    miDebuggerPath = '/usr/bin/gdb',
                --    cwd = vim.fn.getcwd,
                --    program = rustPath,
                --},
                {
                    name = "Launch file",
                    type = "lldb",  -- codelldb
                    request = "launch",
                    program = rustPath,
                    cwd = vim.fn.getcwd,
                    stopOnEntry = false,
                    terminal = "integrated",
                    showDisassembly = false,
                    initCommands = function()
                        -- Find out where to look for the pretty printer Python module
                        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

                        local script_import = 'command script import "' ..
                            rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                        local commands = {}
                        local file = io.open(commands_file, 'r')
                        if file then
                            for line in file:lines() do
                                table.insert(commands, line)
                            end
                            file:close()
                        end
                        table.insert(commands, 1, script_import)

                        return commands
                    end,
                },
                --{
                --    name = 'Launch',
                --    type = 'lldb',
                --    request = 'launch',
                --    program = rustPath,
                --    cwd = vim.fn.getcwd,
                --    stopOnEntry = false,
                --    args = {},
                --    runInTerminal = false,
                --    initCommands = function()
                --        -- Find out where to look for the pretty printer Python module
                --        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

                --        local script_import = 'command script import "' ..
                --            rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                --        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                --        local commands = {}
                --        local file = io.open(commands_file, 'r')
                --        if file then
                --            for line in file:lines() do
                --                table.insert(commands, line)
                --            end
                --            file:close()
                --        end
                --        table.insert(commands, 1, script_import)

                --        return commands
                --    end,
                --},
                --{
                --    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
                --    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                --    name = "Attach to process",
                --    type = 'lldb', -- Adjust this to match your adapter name (`dap.adapters.<name>`)
                --    request = 'attach',
                --    pid = require('dap.utils').pick_process,
                --    args = {},
                --},
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
