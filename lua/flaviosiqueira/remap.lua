local function get_visual_selection()
  return ""
end


-- File explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- remap to move indented text: theprimeagen
vim.keymap.set("v", "J", [[:m '>+1<CR>gv=gv]])
vim.keymap.set("v", "K", [[:m '<-2<CR>gv=gv]])

-- maintain visual selection when indenting
vim.keymap.set("n", "J", "mzJ`z")
-- maintain cursor position when page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "NzzzV")

-- move between projects
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("s", "\"", function()
    local line = get_visual_selection()
    print(line)
    if string.find(line, "\".*\"") then
        return line
    elseif string.find(line, "\'") then
        return string.sub(line, 1, string.find(line, "\'") - 1) .. "\"\""
    end
    return "\"\""
end, { buffer = true })

