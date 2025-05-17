--
--  this is where I have my custom fns for evaluating code
--

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

-- vim.keymap.set('n', '<leader><CR>', function()
--   -- if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' or vim.bo.filetype == 'sh' then
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
--   vim.cmd 'silent! normal j'
--   --else
--   --  print 'Not a julia or python file.'
--   --end
-- end, { desc = 'Send line to REPL' })


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
    vim.cmd '!echo && python3 %'
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

-- Function to insert schedule template with header and todo section
function CreateScheduleTemplate()
  -- Get current cursor position
  local line = vim.api.nvim_win_get_cursor(0)[1]
  -- Get current date in the format "Thursday, January 2, 2025"
  local current_date = os.date '%A, %B %d, %Y'
  -- Create template sections
  local template = {
    '# ' .. current_date,
    '',
    '## Todo',
    '- [ ] ',
    '- [ ] ',
    '- [ ] ',
    '',
    '## Schedule',
  }
  -- Add schedule entries from 8:00 to 18:00
  for hour = 8, 18 do
    -- Format hour with leading zero if needed
    local time = string.format('%02d:00: ', hour)
    table.insert(template, time)
  end
  -- Insert template at current cursor position
  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, template)
  -- Move cursor to first todo item (4 lines down from start)
  vim.api.nvim_win_set_cursor(0, { line + 3, 6 })
end

-- Create a command to call the function
vim.api.nvim_create_user_command('Schedule', CreateScheduleTemplate, {})
vim.keymap.set('n', '<leader>gt', CreateScheduleTemplate, { noremap = true, desc = 'Insert schedule template' })

-- Function to insert weekly workout planning template
function CreateWorkoutTemplate()
  -- Get current cursor position
  local line = vim.api.nvim_win_get_cursor(0)[1]
  -- Get current date
  local current_date = os.time()
  -- Find Monday of current week
  local weekday = tonumber(os.date('%w', current_date)) -- 0 = Sunday, 1 = Monday, ...
  local days_to_monday = weekday == 0 and -6 or -(weekday - 1) -- Adjust to get to Monday
  local monday = current_date + (days_to_monday * 24 * 60 * 60)
  -- Create template header
  local template = {
    '# Workout Plan: Week of ' .. os.date('%B %d, %Y', monday),
    '',
    '| Date | Day | Workout Type | Exercises | Notes |',
    '|------|-----|--------------|-----------|-------|',
  }
  -- Add entries for each day of the week
  for i = 0, 6 do
    local day_timestamp = monday + (i * 24 * 60 * 60)
    local date_str = os.date('%Y-%m-%d', day_timestamp)
    local day_str = os.date('%A', day_timestamp)
    table.insert(template, string.format('| %s | %s | | | |', date_str, day_str))
  end
  -- Add a few blank lines and some example categories at the bottom
  table.insert(template, '')
  table.insert(template, '## Workout Categories:')
  table.insert(template, '- Strength Training')
  table.insert(template, '- Cardio')
  table.insert(template, '- HIIT')
  table.insert(template, '- Rest/Recovery')
  table.insert(template, '- Flexibility/Mobility')
  -- Insert template at current cursor position
  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, template)
  -- Position cursor at first workout entry
  vim.api.nvim_win_set_cursor(0, { line + 4, 24 }) -- Position after "| " in first day's row
end
-- Create a command to call the function
vim.api.nvim_create_user_command('WorkoutPlan', CreateWorkoutTemplate, {})


function HasRightSplit()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_pos = vim.api.nvim_win_get_position(curr_win)

  for _, win in ipairs(wins) do
    if win ~= curr_win then
      local pos = vim.api.nvim_win_get_position(win)
      if pos[2] > curr_pos[2] then  -- Column position is greater (to the right)
        return true
      end
    end
  end
  return false
end

function CopyParagraphToTerminal()
  if HasRightSplit() then
    -- Save current position
    local curr_win = vim.api.nvim_get_current_win()
    
    -- Find the window to the right
    local wins = vim.api.nvim_tabpage_list_wins(0)
    local curr_pos = vim.api.nvim_win_get_position(curr_win)
    
    for _, win in ipairs(wins) do
      if win ~= curr_win then
        local pos = vim.api.nvim_win_get_position(win)
        if pos[2] > curr_pos[2] then  -- Window is to the right
          -- Go to that window
          vim.api.nvim_set_current_win(win)
          -- Paste the text
          vim.cmd('normal! pa')
          --vim.cmd('normal! a')
          -- vim.cmd('normal! <CR><CR>')
          --vim.cmd('call feedkeys("\r")')
          --vim.cmd('call feedkeys("\r")')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'n', true)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'n', true)
          --vim.cmd('normal! i')  -- Enter insert mode
          --vim.api.nvim_put(vim.fn.getreg('"'):split('\n'), 'c', true, true)
          -- Return to original window
          --
          -- Wait a short time to ensure keys are processed
          vim.defer_fn(function()
            -- Switch back to original window
            vim.api.nvim_set_current_win(curr_win)
          end, 200)  -- 100ms delay
          break
        end
      end
    end
  end
end

function SendToTerminal(text)
  -- Find the terminal window/buffer
  local term_win = nil
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local curr_win = vim.api.nvim_get_current_win()
  local curr_pos = vim.api.nvim_win_get_position(curr_win)
  for _, win in ipairs(wins) do
    if win ~= curr_win then
      local pos = vim.api.nvim_win_get_position(win)
      if pos[2] > curr_pos[2] then
        term_win = win
        break
      end
    end
  end
  if term_win then
    local term_buf = vim.api.nvim_win_get_buf(term_win)
    local job_id = vim.b[term_buf].terminal_job_id
    if job_id then
      vim.fn.chansend(job_id, "%paste\n")
      -- Send text followed by Enter
      -- vim.fn.chansend(job_id, text .. "\n")
      -- return true
      --
      -- Split text into lines and send line by line to preserve indentation
      -- local lines = vim.split(text, "\n")
      -- for _, line in ipairs(lines) do
      --   vim.fn.chansend(job_id, line .. "\n")
      -- end
      -- -- Send an extra newline to execute the code
      -- vim.fn.chansend(job_id, "\n")
      return true
    end
  end
  return false
end

-- function SendParagraphToTerminal()
--   if HasRightSplit() then
--     -- Get current window
--     local curr_win = vim.api.nvim_get_current_win()
--     -- Visual select inner paragraph, then copy it
--     vim.cmd('normal! vip"ay')
--     -- Move to the right split
--     -- vim.cmd('call feedkeys(\"\<A-l>\")')
--     -- Paste the text
--     vim.cmd('normal! p')
--     -- Press Enter twice
--     vim.cmd('normal! a')
--     vim.cmd('call feedkeys("\r")')
--     vim.cmd('call feedkeys("\r")')
--     -- Move back to the left split
--     -- vim.cmd('call feedkeys("\<A-h>")')
--     -- Return to the original window
--     vim.api.nvim_set_current_win(curr_win)
--   else
--     vim.cmd 'silent! normal V"ay'
--     vim.cmd('vsplit')
--     vim.cmd('terminal')
--     vim.cmd('startinsert')
--   end
-- end


-- vim.keymap.set('n', '<leader><CR>', function()
--   -- if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' or vim.bo.filetype == 'sh' then
--   --print('Hello')
--   if vim.env.TMUX ~=nil then
--     vim.cmd 'silent! normal V"ay'
--     vim.cmd 'silent! redir! > buffer.txt'
--     vim.cmd 'silent! echo @a'
--     vim.cmd 'silent! redir END'
--     vim.fn.system 'tmux load-buffer buffer.txt'
--     vim.fn.system 'tmux select-pane -R'
--     vim.fn.system 'tmux paste-buffer'
--     vim.fn.system 'tmux select-pane -L'
--     vim.fn.system 'rm buffer.txt'
--     vim.cmd 'silent! normal j'
--   else
--     if not HasRightSplit() then
--       vim.cmd 'silent! normal V"ay'
--       vim.cmd('vsplit')
--       vim.cmd('terminal')
--       vim.cmd('startinsert')
--     else
--       -- CopyParagraphToTerminal()
--       vim.cmd 'silent! normal V"ay'
--       SendToTerminal(vim.fn.getreg('"'))
--     end
--   end
-- end, { desc = 'Send line to REPL' })



function SendCode()
  -- if vim.bo.filetype == 'julia' or vim.bo.filetype == 'python' or vim.bo.filetype == 'quarto' then
  --print('Hello')
  if vim.env.TMUX ~=nil then
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
    if not HasRightSplit() then
      vim.cmd('vsplit')
      vim.cmd('terminal')
      vim.cmd('startinsert')
    else
      local mode = vim.api.nvim_get_mode().mode
      print(mode)
      if mode:match('^V') then
        print("using y")
        vim.cmd('normal! y')
      else
        print("usig yip")
        -- Yank current paragraph
        vim.cmd('normal! yip')
      end
      CopyParagraphToTerminal()
      -- vim.cmd 'silent! normal vip"ay'
      -- SendToTerminal(vim.fn.getreg('"'))
      --SendParagraphToTerminal()
    end
  end
end

vim.keymap.set('v', '<leader><CR>', function()
  SendCode()
end, { desc = 'Send selection to REPL' })

vim.keymap.set('n', '<leader><CR>', function()
  SendCode()
end, { desc = 'Send paragraph to REPL' })

vim.keymap.set('n', '<leader>p', function()
  SendCode()
end, { desc = 'Send paragraph to REPL' })

-- -- Function to visually select the current function using Treesitter
-- function SelectCurrentFunction()
--   -- Ensure treesitter is available
--   if not pcall(require, 'nvim-treesitter') then
--     print("Error: nvim-treesitter is not installed")
--     return
--   end
--
--   -- Get the current node at cursor position
--   local ts_utils = require('nvim-treesitter.ts_utils')
--   local current_node = ts_utils.get_node_at_cursor()
--
--   if not current_node then
--     print("No treesitter node found at cursor")
--     return
--   end
--
--   -- Walk up the tree to find a function definition node
--   local function_node = current_node
--
--   while function_node do
--     local node_type = function_node:type()
--
--     -- Check for common function node types across languages
--     -- Add more types based on the languages you use
--     if node_type:match("function") or 
--       node_type:match("method") or 
--       node_type == "function_definition" or
--       node_type == "method_definition" or
--       node_type == "function_declaration" or
--       node_type == "method_declaration" then
--       break
--     end
--
--     function_node = function_node:parent()
--   end
--
--   if not function_node then
--     print("No function found at cursor position")
--     return
--   end
--
--   -- Get function range
--   local start_row, start_col, end_row, end_col = function_node:range()
--
--   -- Set visual selection
--   vim.fn.cursor(start_row + 1, start_col + 1)
--   vim.cmd("normal! v")
--   vim.fn.cursor(end_row + 1, end_col + 1)
-- end
--
-- -- Map the function to a key combination (adjust as needed)
-- vim.api.nvim_set_keymap('n', '<leader>vf', 
--   '<cmd>lua SelectCurrentFunction()<CR>', 
--   {noremap = true, silent = true})

function SelectCurrentFunctionWithDecorators()
  -- Ensure treesitter is available
  if not pcall(require, 'nvim-treesitter') then
    print("Error: nvim-treesitter is not installed")
    return
  end

  -- Get the current node at cursor position
  local ts_utils = require('nvim-treesitter.ts_utils')
  local current_node = ts_utils.get_node_at_cursor()

  if not current_node then
    print("No treesitter node found at cursor")
    return
  end

  -- Walk up the tree to find a function definition node
  local function_node = current_node

  while function_node do
    local node_type = function_node:type()

    -- Check for common function node types across languages
    if node_type:match("function") or 
      node_type:match("method") or 
      node_type == "function_definition" or
      node_type == "method_definition" or
      node_type == "function_declaration" or
      node_type == "method_declaration" then
      break
    end

    function_node = function_node:parent()
  end

  if not function_node then
    print("No function found at cursor position")
    return
  end

  -- Get function range
  local start_row, start_col, end_row, end_col = function_node:range()

  -- Check for decorators before the function
  local decorator_start_row = start_row
  local prev_sibling = function_node:prev_sibling()

  -- Look for decorators (different languages may have different node types)
  while prev_sibling do
    local node_type = prev_sibling:type()

    if node_type == "decorator" or 
      node_type == "decorator_list" or 
      node_type == "annotation" or
      node_type == "decorator_declaration" then
      local dec_start, _, _, _ = prev_sibling:range()
      decorator_start_row = dec_start
      prev_sibling = prev_sibling:prev_sibling()
    else
      -- Stop if we find a non-decorator node
      break
    end
  end

  -- Set visual selection including decorators if found
  vim.fn.cursor(decorator_start_row + 1, 1)  -- Start from beginning of line for decorators
  vim.cmd("normal! v")
  vim.fn.cursor(end_row + 1, end_col + 1)
end

-- Map the function to a key combination
vim.api.nvim_set_keymap('n', '<leader>vf', 
  '<cmd>lua SelectCurrentFunctionWithDecorators()<CR>', 
  {noremap = true, silent = true})
