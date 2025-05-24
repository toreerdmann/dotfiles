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
    vim.cmd '!uv run  %'
  elseif vim.bo.filetype == 'c' then
    vim.cmd ':w'
    vim.cmd '!cc % && echo && ./a.out'
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

-- Store compilation commands for each buffer
local compile_commands = {}

-- Function to get default compile command based on filetype
local function get_default_command()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand '%'

  -- Default commands for various filetypes
  local defaults = {
    python = 'uv run python ' .. filename,
    c = 'cc -Wall ' .. filename .. ' && ./a.out',
    cpp = 'c++ -Wall ' .. filename .. ' && ./a.out',
    rust = 'rustc ' .. filename .. ' && ./' .. vim.fn.fnamemodify(filename, ':r'),
    javascript = 'node ' .. filename,
    typescript = 'ts-node ' .. filename,
    go = 'go run ' .. filename,
    lua = 'lua ' .. filename,
    java = 'javac ' .. filename .. ' && java ' .. vim.fn.fnamemodify(filename, ':r'),
  }

  return defaults[filetype] or ''
end

-- Function to set or get the compilation command for the current buffer
local function get_or_set_compile_command()
  local bufnr = vim.api.nvim_get_current_buf()

  if not compile_commands[bufnr] then
    local current_file = vim.fn.expand '%'
    local default_cmd = get_default_command()

    if default_cmd ~= '' then
      -- We have a default suggestion, ask if user wants to use it
      local default_for_display = default_cmd:gsub(vim.fn.escape(current_file, '.-+*?()[]{}|'), '%%')
      local choices = {
        string.format('Use default: %s', default_for_display),
        'Enter custom command',
      }

      vim.ui.select(choices, {
        prompt = 'Compile/run command:',
      }, function(choice, idx)
        if idx == 1 then
          -- Use default
          compile_commands[bufnr] = default_cmd
          vim.notify('Compile command set: ' .. compile_commands[bufnr], vim.log.levels.INFO)
        elseif idx == 2 then
          -- Enter custom
          vim.ui.input({
            prompt = 'Enter custom command (% for current file): ',
            default = '',
          }, function(input)
            if input and input ~= '' then
              compile_commands[bufnr] = input:gsub('%%', current_file)
              vim.notify('Compile command set: ' .. compile_commands[bufnr], vim.log.levels.INFO)
              vim.cmd('belowright split | terminal ' .. compile_commands[bufnr])
              vim.cmd 'startinsert'
            end
          end)
        end
      end)
    else
      -- No default for this filetype, just prompt
      vim.ui.input({
        prompt = 'Compile/run command (% for current file): ',
        default = '',
      }, function(input)
        if input and input ~= '' then
          compile_commands[bufnr] = input:gsub('%%', current_file)
          vim.notify('Compile command set: ' .. compile_commands[bufnr], vim.log.levels.INFO)
          vim.cmd('belowright split | terminal ' .. compile_commands[bufnr])
          vim.cmd 'startinsert'
        end
      end)
    end
    return nil
  else
    -- Return existing command
    return compile_commands[bufnr]
  end
end

-- Function to edit the compilation command
local function edit_compile_command()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.fn.expand '%'
  local current_command = compile_commands[bufnr] or ''

  -- Get the default command for comparison
  local default_cmd = get_default_command()
  local default_for_display = default_cmd:gsub(vim.fn.escape(current_file, '.-+*?()[]{}|'), '%%')

  -- Prepare choices for the select menu
  local choices = {
    current_command ~= '' and 'Edit current: ' .. current_command:gsub(vim.fn.escape(current_file, '.-+*?()[]{}|'), '%%') or 'Set new command',
    default_cmd ~= '' and 'Use default: ' .. default_for_display or nil,
    'Enter new command',
  }

  -- Filter out nil entries
  choices = vim.tbl_filter(function(val)
    return val ~= nil
  end, choices)

  vim.ui.select(choices, {
    prompt = 'Compile command options:',
  }, function(choice, idx)
    if idx == 1 and current_command ~= '' then
      -- Edit current command
      vim.ui.input({
        prompt = 'Edit compile command (% for current file): ',
        default = current_command:gsub(vim.fn.escape(current_file, '.-+*?()[]{}|'), '%%'),
      }, function(input)
        if input and input ~= '' then
          compile_commands[bufnr] = input:gsub('%%', current_file)
          vim.notify('Compile command updated: ' .. compile_commands[bufnr], vim.log.levels.INFO)
        end
      end)
    elseif (idx == 2 and current_command ~= '') or (idx == 1 and current_command == '' and default_cmd ~= '') then
      -- Use default
      compile_commands[bufnr] = default_cmd
      vim.notify('Compile command set to default: ' .. compile_commands[bufnr], vim.log.levels.INFO)
    else
      -- Enter new command
      vim.ui.input({
        prompt = 'Enter new compile command (% for current file): ',
        default = '',
      }, function(input)
        if input and input ~= '' then
          compile_commands[bufnr] = input:gsub('%%', current_file)
          vim.notify('Compile command updated: ' .. compile_commands[bufnr], vim.log.levels.INFO)
        end
      end)
    end
  end)
end

-- Function to execute the compilation command
local function execute_compile_command()
  local command = get_or_set_compile_command()

  if command then
    -- Create a new terminal buffer and run the command
    vim.cmd('belowright split | terminal ' .. command)

    -- -- Set up an autocmd to automatically close the terminal when the process ends
    -- vim.cmd [[
    --   augroup close_term
    --     autocmd!
    --     autocmd TermClose <buffer> if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
    --   augroup END
    -- ]]

    -- Enter terminal mode
    vim.cmd 'startinsert'
  end
end

-- Set up keymappings
vim.keymap.set('n', '<leader>jj', execute_compile_command, { noremap = true, silent = true, desc = 'Execute compile command' })
vim.keymap.set('n', '<leader>je', edit_compile_command, { noremap = true, silent = true, desc = 'Edit compile command' })
