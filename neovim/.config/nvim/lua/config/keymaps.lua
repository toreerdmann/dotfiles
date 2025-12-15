-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- local has_repl, repl = pcall(require, "send-to-repl")
-- if has_repl then
--   -- send-to-repl keymaps
--   vim.keymap.set("n", "<leader>l", repl.send_line, { desc = "Send line to REPL" })
--   vim.keymap.set("n", "<leader>p", repl.send_word, { desc = "Send word to REPL" })
--   vim.keymap.set("n", "<leader><CR>", repl.send_paragraph, { desc = "Send paragraph to REPL" })
--   vim.keymap.set("v", "<leader><CR>", repl.send_visual, { desc = "Send selection to REPL" })
--   vim.keymap.set("t", "<C-]>", "<C-\\><C-N><C-w>w")
--   vim.keymap.set("i", "<C-]>", "<C-\\><C-N><C-w>wa")
--   vim.keymap.set("n", "<C-]>", "<C-w>wa")
-- end

vim.keymap.set("n", "<C-n>", ":bn<CR>")
vim.keymap.set("n", "<C-p>", ":bp<CR>")
