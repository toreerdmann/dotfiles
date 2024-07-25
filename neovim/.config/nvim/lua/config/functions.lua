--
--  this is where I have my custom fns for evaluating code
--

vim.keymap.set('n', '<leader>p', function()
  -- if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' then
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
  -- else
  --   print 'Not a julia or python file.'
  -- end
end, { desc = 'Send paragraph to REPL' })

vim.keymap.set('n', '<leader>o', function()
  if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' then
    --print('Hello')
    vim.cmd 'silent! normal vip"ay'
    vim.cmd 'silent! redir! > buffer.txt'
    vim.cmd 'silent! echo @a'
    vim.cmd 'silent! redir END'
    vim.fn.system 'tmux load-buffer buffer.txt'
    vim.fn.system 'tmux select-pane -R'
    vim.fn.system 'tmux paste-buffer'
    vim.fn.system 'rm buffer.txt'
  else
    print 'Not a julia or python file.'
  end
end, { desc = 'Send paragraph to REPL and go over' })

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
end, { desc = 'Send line to REPL' })

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
end, { desc = 'Send selection to REPL' })

-- -- this can be annoying when typing
-- vim.keymap.set('i', '<leader><CR>', function()
--   --print('Hello')
--   vim.cmd 'silent! normal V"ay'
--   vim.cmd 'silent! redir! > buffer.txt'
--   vim.cmd 'silent! echo @a'
--   vim.cmd 'silent! redir END'
--   vim.fn.system 'tmux load-buffer buffer.txt'
--   vim.fn.system 'tmux select-pane -R'
--   vim.fn.system 'tmux paste-buffer'
--   vim.fn.system 'tmux select-pane -L'
--   vim.fn.system 'rm buffer.txt'
-- end, { desc = 'Send current line to REPL' })

-- For python
vim.keymap.set('n', '<C-j>', function()
  -- print('Hello')
  if vim.bo.filetype == 'python' then
    vim.cmd ':w'
    vim.cmd '!python3 %'
  elseif vim.bo.filetype == 'cpp' then
    vim.cmd ':w'
    vim.cmd '!g++ -std=c++11 % && ./a.out'
  else
    print 'not a python/cpp file'
  end
end, { desc = 'Run current file.' })
