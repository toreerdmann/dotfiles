vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<C-n>', ':bn<cr>')
vim.keymap.set('n', '<C-p>', ':bp<cr>')
vim.keymap.set('n', '<leader>bd', ':bp | bd# <cr>', { desc = 'Close current buffer' })

-- vim.keymap.set('n', ',,', ':bp<cr>')

-- vim.keymap.set('v', "'y", '"+y')

vim.keymap.set('i', 'jj', '<Esc>', { silent = true })

vim.keymap.set('i', '<C-f>', '<C-o>l')
vim.keymap.set('i', '<C-b>', '<C-o>h')
vim.keymap.set('i', '<C-n>', '<C-o>j')
vim.keymap.set('i', '<C-p>', '<C-o>k')

vim.keymap.set('t', '<A-h>', '<C-\\><C-N><C-w>h')
vim.keymap.set('t', '<A-j>', '<C-\\><C-N><C-w>j')
vim.keymap.set('t', '<A-k>', '<C-\\<C-N><C-w>k')
vim.keymap.set('t', '<A-l>', '<C-\\<C-N><C-w>l')
vim.keymap.set('i', '<A-h>', '<C-\\<C-N><C-w>h')
vim.keymap.set('i', '<A-j>', '<C-\\<C-N><C-w>j')
vim.keymap.set('i', '<A-k>', '<C-\\<C-N><C-w>k')
vim.keymap.set('i', '<A-l>', '<C-\\<C-N><C-w>l')
vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- vim.keymap.set("x", "<leader>p", "\"_dP")

-- vim.keymap.set('n', '<leader>o', 'normal :Oil %:p:h')

vim.keymap.set('n', '<leader>o', function()
  vim.cmd ':Oil %:p:h'
end, { desc = 'Open oil in parent folder of current buffer.' })
