-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "s")

-- Bind Ctrl-f to Esc in all modes (except normal, which flashes the current line)
vim.keymap.set({ "i", "v", "s", "x", "o", "c" }, "<C-f>", "<Esc>")
vim.keymap.set("n", "<C-f>", require("../commands").flash_line, { desc = "Highlight the current line" })

-- Move around in visual mode
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

-- Open buffer picker
vim.keymap.set("n", "<leader>b", function()
  Snacks.picker.buffers()
end, { desc = "Open buffer picker" })

-- Switch to the previous buffer
vim.keymap.set("n", "<leader><leader>", "<cmd>e #<cr>", { desc = "Switch to previous buffer" })

-- Toggle floaterm
vim.keymap.set("n", "<C-Space>", "<cmd>FloatermToggle<cr>", { desc = "Floaterm toggle" })
vim.keymap.set("t", "<C-Space>", "<cmd>FloatermToggle<cr>", { desc = "Floaterm toggle" })

-- Indent/Unindent lines in visual mode
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent line" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent line" })

--  Comment/Uncomment lines
local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
local comment = require("Comment.api")

vim.keymap.set("n", "<C-/>", comment.toggle.linewise.current, { desc = "Toggle line comment" })
vim.keymap.set("x", "<C-/>", function()
  vim.api.nvim_feedkeys(esc, "nx", false)
  comment.toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment in visual selection" })

-- Rebind <leader>b -> <leader>B
vim.keymap.del("n", "<leader>bb")
vim.keymap.del("n", "<leader>bd")
vim.keymap.del("n", "<leader>bo")
vim.keymap.del("n", "<leader>bD")

vim.keymap.set("n", "<leader>Bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>Bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>BD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- Swap <leader>sb and <leader>sB
vim.keymap.set("n", "<leader>sB", function()
  Snacks.picker.lines()
end, { desc = "Hop to word" })

vim.keymap.set("n", "<leader>sb", function()
  Snacks.picker.grep_buffers()
end, { desc = "Hop to symbol" })
