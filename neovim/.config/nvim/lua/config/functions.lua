--
--  this is where I have my custom fns for evaluating code
--

vim.keymap.set('n', '<leader>p', function()
  if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' then
    --print('Hello')
    vim.cmd 'silent! normal vip"ay'
    vim.cmd 'silent! redir! > buffer.txt'
    vim.cmd 'silent! echo @a'
    vim.cmd 'silent! redir END'
    vim.fn.system 'tmux load-buffer buffer.txt'
    vim.fn.system 'tmux select-pane -R'
    vim.fn.system 'tmux paste-buffer'
    vim.fn.system 'tmux select-pane -L'
    vim.fn.system 'rm buffer.txt'
  else
    print 'Not a julia or python file.'
  end
end, { desc = 'Send paragraph to REPL' })

vim.keymap.set('n', '<leader><CR>', function()
  if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' then
    --print('Hello')
    vim.cmd 'silent! normal V"ay'
    vim.cmd 'silent! redir! > buffer.txt'
    vim.cmd 'silent! echo @a'
    vim.cmd 'silent! redir END'
    vim.fn.system 'tmux load-buffer buffer.txt'
    vim.fn.system 'tmux select-pane -R'
    vim.fn.system 'tmux paste-buffer'
    vim.fn.system 'tmux select-pane -L'
    vim.fn.system 'rm buffer.txt'
    vim.cmd 'silent! normal j'
  else
    print 'Not a julia or python file.'
  end
end, { desc = 'Send paragraph to REPL' })

vim.keymap.set('v', '<leader><CR>', function()
  --print('Hello')
  vim.cmd 'silent! normal "ay'
  vim.cmd 'silent! redir! > buffer.txt'
  vim.cmd 'silent! echo @a'
  vim.cmd 'silent! redir END'
  vim.fn.system 'tmux load-buffer buffer.txt'
  vim.fn.system 'tmux select-pane -R'
  vim.fn.system 'tmux paste-buffer'
  vim.fn.system 'tmux select-pane -L'
  vim.fn.system 'rm buffer.txt'
end, { desc = 'Send paragraph to REPL' })

-- For python
vim.keymap.set('n', '<C-j>', function()
  -- print('Hello')
  vim.cmd ':w'
  if vim.bo.filetype == 'python' then
    vim.cmd '!python3 %'
  end
  if vim.bo.filetype == 'cpp' then
    vim.cmd '!g++ -std=c++11 % && ./a.out'
  end
end, { desc = 'Run current file.' })
