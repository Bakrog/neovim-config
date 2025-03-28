local augroup = vim.api.nvim_create_augroup
local FlavioSiqueiraGroup = augroup("FlavioSiqueira", {})

local autocmd = vim.api.nvim_create_autocmd

autocmd('DirChanged', {
    group = FlavioSiqueiraGroup,
    callback = function(args)
        if args.match == "global" then
            local file = io.open(args.file .. "/.nvmrc", "r")
            if file ~= nil then
                local nvmrc = file:read("*all"):gsub("\n", "")
                if nvmrc ~= nil and nvmrc ~= "" then
                    local node_path = vim.fn.expand("~/.local/share/nvm/v" .. nvmrc .. "/bin")
                    --vim.g.node_host_prog = node_path .. "/node"
                    vim.env.PATH = node_path .. ":" .. vim.env.PATH
                end
                file:close()
            end
        end
    end
})

autocmd('LspAttach', {
    group = FlavioSiqueiraGroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client ~= nil and client.name == 'ruff' then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
        end
        -- Keymaps
        local opts = { buffer = args.buf }
        local builtin = require('telescope.builtin')
        vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, opts)
        vim.keymap.set("n", "<leader>sp", builtin.diagnostics, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>gr", builtin.lsp_references, opts)
        vim.keymap.set("n", "<leader>gs", builtin.lsp_document_symbols, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        -- Vector database for LLM
        if client ~= nil and client.name ~= "vectorcode-server" then
            vim.lsp.config.vectorcode_server = {
                root_dir = client.root_dir
            }
            local cacher = require("vectorcode.config").get_cacher_backend()
            if not cacher.buf_is_enabled(args.buf) then
                cacher.async_check("config", function()
                    cacher.register_buffer(
                        args.buf,
                        {
                            project_root = client.root_dir,
                            n_query = 10,
                        }
                    )
                end, function()
                    vim.notify("Failed vector check")
                end)
            end
        end
    end
})

vim.cmd([[cab cc CodeCompanion]])

-- Enter insert mode when switching to terminal
autocmd("TermOpen", {
    command = "setlocal listchars= nonumber norelativenumber nocursorline",
})

autocmd("TermOpen", {
    pattern = "term://*",
    command = "startinsert",
})

-- Close terminal buffer on process exit
autocmd("BufLeave", {
    pattern = "term://*",
    command = "stopinsert",
})

return {}
