-- Map the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false

-- Set font
vim.g.have_nerd_fonts = true

--vim.g.tokyonight_dark_float = false

-- Set netrw configurations
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Set a fat cursor
vim.opt.guicursor = ""

-- Set relative line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Indenting
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = false

-- Set undotree plugin settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Disable highlighting search
vim.opt.hlsearch = false
-- Enable incremental search
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

