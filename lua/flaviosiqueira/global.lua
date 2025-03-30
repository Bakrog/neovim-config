-- lua/flaviosiqueira/global.lua
-- Global Neovim settings

-- Set leader keys
vim.g.mapleader = " "       -- Main leader key (Space)
vim.g.maplocalleader = "\\" -- Local leader key (Backslash)

-- Set blinkcmp
vim.g.lazyvim_blink_main = true

-- Set netrw configurations
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Editor behavior
vim.opt.guicursor = ""        -- Use block cursor in all modes
vim.opt.nu = true             -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.wrap = false          -- Disable line wrapping
vim.opt.scrolloff = 8         -- Keep 8 lines visible above/below cursor when scrolling
vim.opt.sidescrolloff = 8     -- Keep 8 columns visible when side-scrolling
vim.opt.signcolumn = "yes"    -- Always show the sign column
vim.opt.colorcolumn = "80"    -- Show color column at 80 characters
vim.opt.termguicolors = true  -- Enable true color support in terminal
vim.opt.mouse = "a"           -- Enable mouse support in all modes

-- Indentation
vim.opt.tabstop = 4        -- Number of visual spaces per TAB
vim.opt.softtabstop = 4    -- Number of spaces TAB inserts in Insert mode
vim.opt.shiftwidth = 4     -- Number of spaces for autoindent
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Enable smart autoindenting

-- Search behavior
vim.opt.hlsearch = true   -- Highlight search results
vim.opt.incsearch = true  -- Show search results incrementally
vim.opt.ignorecase = true -- Ignore case when searching...
vim.opt.smartcase = true  -- ...unless the query contains uppercase letters

-- Files and Backups
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false   -- Disable backup files
vim.opt.undofile = true  -- Enable persistent undo
vim.opt.undodir = vim.fn.stdpath("data") ..
    "/undodir"           -- Set undo directory (ensure it exists, handled by undotree plugin init)
vim.opt.updatetime = 300 -- Faster update time for plugins (e.g., git signs)
vim.opt.timeoutlen = 500 -- Shorter timeout for key sequences

-- Folding (Basic Neovim settings, UFO plugin controls actual folding)
vim.opt.foldmethod = 'manual' -- Default fold method (UFO overrides with providers)
vim.opt.foldenable = false    -- Folds are disabled by default, UFO enables/manages them
vim.opt.foldlevel = 99        -- Start with folds closed (UFO handles levels)
vim.opt.foldlevelstart = 99   -- Start new buffers with folds closed
vim.opt.foldcolumn = '0'      -- Don't show fold column by default (UFO can show virt text)

-- Filetype detection and plugins
vim.api.nvim_command('filetype plugin on')        -- Enable filetype detection
vim.api.nvim_command('filetype plugin indent on') -- Enable filetype-specific indentation

-- Font settings (used by plugins like devicons)
vim.g.have_nerd_fonts = true

-- Misc settings
vim.opt.completeopt = { "menuone", "noselect" } -- Completion options
vim.opt.isfname:append("@-@") -- Allow more characters in filenames
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below
vim.opt.laststatus = 3 -- Use global status line (lualine handles this)
vim.opt.showmode = false -- Don't show mode in command line (lualine shows it)
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Define invisible characters

-- Ensure undo directory exists
if vim.fn.isdirectory(vim.opt.undodir:get()[0]) == 0 then
    vim.fn.mkdir(vim.opt.undodir:get()[0], "p")
end
