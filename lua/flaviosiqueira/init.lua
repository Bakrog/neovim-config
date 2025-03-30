-- lua/flaviosiqueira/init.lua
-- Main Neovim configuration entry point

-- Load global settings first
require("flaviosiqueira.global")
-- Load custom key mappings
require("flaviosiqueira.remap")

-- Bootstrap lazy.nvim package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- Use stable branch
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Import all plugin configurations from the plugins directory
        { import = "flaviosiqueira.plugins" },
    },
    -- Configure lazy.nvim options
    install = {
        -- Install plugins with a light colorscheme for better visibility
        colorscheme = { "rose-pine" }, -- Or your preferred theme
    },
    checker = {
        enabled = true, -- Automatically check for plugin updates
        notify = true, -- Notify about updates
    },
    performance = {
        rtp = {
            -- Disable scanning of default runtime paths for performance
            disabled_plugins = {
                 "gzip",
                 "matchit",
                 "matchparen",
                 -- "netrwPlugin", -- Disable if using nvim-tree or similar
                 "tarPlugin",
                 "tohtml",
                 "tutor",
                 "zipPlugin",
            },
        },
    },
    change_detection = {
        -- Automatically reload Neovim when lazy.nvim config changes
        enabled = true,
        notify = true,
    },
    ui = {
        border = "rounded", -- Use rounded borders for the lazy.nvim UI
    },
    -- Optional: Set default options for plugins
    -- defaults = {
    --   lazy = true, -- Default plugins to lazy load
    -- },
})

-- Optional: Load the colorscheme immediately after setup if not handled by the plugin itself
-- vim.cmd("colorscheme rose-pine")

print("Neovim configuration loaded.")
