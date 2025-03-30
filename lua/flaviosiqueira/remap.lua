-- lua/flaviosiqueira/remap.lua
-- Global keybindings

local map = vim.keymap.set

-- File explorer toggle (using built-in netrw for simplicity)
map("n", "<leader>pv", vim.cmd.Ex, { desc = "Toggle File Explorer" })

-- Move selected lines up/down in Visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Up" })

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join Lines" })

-- Center cursor when scrolling half pages
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down Half Page" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up Half Page" })

-- Center cursor when jumping between search results
map("n", "n", "nzzzv", { desc = "Next Search Result" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- Open tmux sessionizer (external dependency)
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Find Tmux Session" })

-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to System Clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank Line to System Clipboard" })

-- Delete to black hole register (avoids overwriting default register)
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to Black Hole" })

-- Paste from system clipboard (use standard 'p'/'P')

-- Navigate windows
map("n", "<C-h>", "<C-w>h", { desc = "Navigate Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate Right" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Navigate buffers
map("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Close Buffer" })

-- Clear search highlighting
map("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlight" })

-- Terminal mappings (if using toggleterm or similar)
-- map("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
