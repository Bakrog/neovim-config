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
                    local node_path = vim.fn.expand("~/.local/share/nvm/v" .. nvmrc ..  "/bin")
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
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    end
})

return {}

