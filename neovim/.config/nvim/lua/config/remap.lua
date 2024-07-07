vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', 'gn', ':bn<cr>')
vim.keymap.set('n', 'gb', ':bp<cr>')
vim.keymap.set('n', 'gd', ':bd<cr>')

vim.keymap.set('v', "'y", '"+y')

vim.keymap.set('i', 'jj', '<Esc>', { silent = true })

--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- vim.keymap.set("x", "<leader>p", "\"_dP")
