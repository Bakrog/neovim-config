-- lua/flaviosiqueira/plugins/99-autocmds.lua
-- Global autocommands and associated logic

local api = vim.api
local group_name = "FlavioSiqueiraCustomGroup"

-- Create custom augroup if it doesn't exist
local augroup_exists, _ = pcall(api.nvim_get_autocmds, { group = group_name })
if not augroup_exists then
    api.nvim_create_augroup(group_name, { clear = true })
end

-- Autocommand to handle Node.js version switching based on .nvmrc
api.nvim_create_autocmd('DirChanged', {
    group = group_name,
    pattern = "*", -- Trigger for any directory change
    callback = function(args)
        -- Only act on global DirChanged events (usually initial load or manual :cd)
        if args.match == "global" then
            local cwd = vim.fn.getcwd()
            local nvmrc_path = cwd .. "/.nvmrc"
            local file = io.open(nvmrc_path, "r")

            if file then
                -- Read version, remove newline, trim whitespace
                local nvm_version = file:read("*a"):gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
                file:close()

                if nvm_version ~= nil and nvm_version ~= "" then
                    -- Construct potential NVM node path (adjust if your NVM setup differs)
                    -- Example assumes NVM stores versions like v18.17.0
                    local node_version_dir = "v" .. nvm_version
                    local nvm_base_path = vim.fn.expand("~/.local/share/nvm") -- Common NVM path
                    local node_path = nvm_base_path .. "/" .. node_version_dir .. "/bin"

                    -- Check if the directory exists before modifying PATH
                    if vim.fn.isdirectory(node_path) == 1 then
                        local current_path = vim.env.PATH or ""
                        -- Prepend Node path only if not already present to avoid duplicates
                        if not string.find(current_path, node_path .. ":", 1, true) then
                            vim.env.PATH = node_path .. ":" .. current_path
                            vim.notify("Switched Node to " .. node_version_dir .. " (PATH updated)", vim.log.levels.INFO)
                            -- Optional: Set global node path for plugins that might need it
                            -- vim.g.node_host_prog = node_path .. "/node"
                        end
                    else
                        vim.notify("NVM version " .. node_version_dir .. " not found at " .. node_path,
                            vim.log.levels.WARN)
                    end
                end
            end
        end
    end,
    desc = "Update PATH based on .nvmrc on directory change"
})

-- Autocommand for LSP Attachments
api.nvim_create_autocmd('LspAttach', {
    group = group_name,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if client == nil then return end

        -- Disable hover for specific linters if main LSP provides it
        if client.name == 'ruff_lsp' or client.name == 'eslint' then
            client.server_capabilities.hoverProvider = false
        end

        -- Common LSP Keymaps (consider moving to a dedicated lsp module if large)
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help") -- Use <C-k> or other
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
        map("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
            "List Workspace Folders")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "Type Definition")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "gr", require("telescope.builtin").lsp_references, "Find References")
        map("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, "Format Buffer")

        -- Diagnostics Keymaps (using vim.diagnostic)
        map("n", "[d", vim.diagnostic.goto_prev, "Go to Previous Diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Go to Next Diagnostic")
        map("n", "<leader>e", vim.diagnostic.open_float, "Show Line Diagnostics")
        map("n", "<leader>q", vim.diagnostic.setloclist, "Send Diagnostics to Loclist")

        -- VectorCode Integration on LspAttach (if VectorCode is loaded)
        if package.loaded["vectorcode"] and client.name ~= "vectorcode-server" and client.root_dir then
            local vc_ok, cacher = pcall(require, "vectorcode.config")
            if vc_ok then
                cacher = cacher.get_cacher_backend()
                -- Check asynchronously if vectorcode is configured for this project root
                cacher.async_check("config", function()
                    -- Register buffer only if enabled and root_dir exists
                    if cacher.buf_is_enabled(bufnr) == false and client.root_dir then
                        cacher.register_buffer(
                            bufnr,
                            { project_root = client.root_dir, n_query = 10 }  -- Adjust n_query as needed
                        )
                        -- vim.notify("VectorCode registered for buffer: " .. bufnr .. " in " .. client.root_dir, vim.log.levels.DEBUG)
                    end
                end, function()
                    vim.notify("Failed VectorCode config check for " .. client.name, vim.log.levels.WARN)
                end)
            end
        end

        -- Apply completion settings if using nvim-cmp
        -- require('cmp_nvim_lsp').on_attach(client, bufnr)

        -- Optional: Highlight symbol under cursor
        -- api.nvim_create_autocmd('CursorHold', {
        --     buffer = bufnr,
        --     callback = function() vim.lsp.buf.document_highlight() end,
        -- })
        -- api.nvim_create_autocmd('CursorMoved', {
        --     buffer = bufnr,
        --     callback = function() vim.lsp.buf.clear_references() end,
        -- })
    end,
    desc = "Setup LSP keymaps and integrations on attach"
})

-- Autocommand to automatically format on save (optional)
api.nvim_create_autocmd("BufWritePre", {
    group = group_name,
    pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.go", "*.rs", "*.zig", "*.json", "*.yaml", "*.toml", "*.md" }, -- Add filetypes to format
    callback = function(args)
        vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 1000 })                                                -- Use sync format on save
    end,
    desc = "Format buffer on save using LSP"
})

-- Autocommand for terminal buffer handling
api.nvim_create_autocmd("TermOpen", {
    group = group_name,
    pattern = "term://*",
    command = "setlocal nonumber norelativenumber nocursorline listchars= NonText: " ..
        " | startinsert",       -- Enter insert mode, simplify statusline
    desc = "Enter insert mode and simplify view in terminal buffers"
})

api.nvim_create_autocmd("BufLeave", {
    group = group_name,
    pattern = "term://*",
    command = "stopinsert", -- Exit insert mode when leaving terminal buffer
    desc = "Exit insert mode when leaving terminal"
})

-- Abbreviation for CodeCompanion command
vim.cmd([[cabbrev cc CodeCompanion]])

-- Return empty table as this file primarily defines autocommands
return {}
