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
  -- if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' then
    --print('Hello')
    vim.cmd 'silent! normal vip"ay'
    vim.cmd 'silent! redir! > buffer.txt'
    vim.cmd 'silent! echo @a'
    vim.cmd 'silent! redir END'
    vim.fn.system 'tmux load-buffer buffer.txt'
    vim.fn.system 'tmux select-pane -R'
    vim.fn.system 'tmux paste-buffer'
    vim.fn.system 'rm buffer.txt'
  --else
  --  print 'Not a julia or python file.'
  --end
end, { desc = 'Send paragraph to REPL and go over' })

vim.keymap.set('n', '<leader><CR>', function()
  -- if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' or vim.bo.filetype == 'sh' then
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
  --else
  --  print 'Not a julia or python file.'
  --end
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

-- eval from beginning
vim.keymap.set('n', '<leader>B', function()
  --print('Hello')
  vim.cmd 'silent! normal ma'
  vim.cmd 'silent! normal Vgg"ay'
  vim.cmd 'silent! redir! > buffer.txt'
  vim.cmd 'silent! echo @a'
  vim.cmd 'silent! redir END'
  vim.cmd 'silent! normal `a'
  vim.fn.system 'tmux load-buffer buffer.txt'
  vim.fn.system 'tmux select-pane -R'
  vim.fn.system 'tmux paste-buffer'
  vim.fn.system 'tmux select-pane -L'
  vim.fn.system 'rm buffer.txt'
end, { desc = 'Select file from beginning to current line and send to REPL' })

-- eval from beginning
vim.keymap.set('n', '<leader>E', function()
  --print('Hello')
  vim.cmd 'silent! normal ma'
  vim.cmd 'silent! normal VG"ay'
  vim.cmd 'silent! redir! > buffer.txt'
  vim.cmd 'silent! echo @a'
  vim.cmd 'silent! redir END'
  vim.cmd 'silent! normal `a'
  vim.fn.system 'tmux load-buffer buffer.txt'
  vim.fn.system 'tmux select-pane -R'
  vim.fn.system 'tmux paste-buffer'
  vim.fn.system 'tmux select-pane -L'
  vim.fn.system 'rm buffer.txt'
end, { desc = 'Select file from beginning to current line and send to REPL' })

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
  elseif vim.bo.filetype == 'c' then
    vim.cmd ':w'
    print 'Running file...'
    --vim.cmd '!cc -Wall -Werror % && echo && ./a.out'
    vim.cmd '!cc -Wall % && echo && ./a.out'
    -- alternative: open buffer
    --vim.cmd ':te "cc % && ./a.out'
    -- vim.cmd 'silent !cc -Wall % && ./a.out'
  else
    print 'not a python/c/cpp file'
  end
end, { desc = 'Run current file.' })
