-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

function BufNextPrev(direction)
  local qf_open = false
  for _, winfo in ipairs(vim.fn.getwininfo()) do
    if winfo.quickfix == 1 and winfo.loclist == 0 then
      qf_open = true
      break
    end
  end
  -- If quickfix is open, navigate it, catching errors at the boundaries
  if qf_open then
    local success
    if direction == 1 then
      -- Try to go to the next file; on failure (end of list), wrap to the first item.
      success = pcall(vim.cmd, "cnfile")
      if not success then
        vim.cmd("cfirst")
      end
    elseif direction == -1 then
      -- Try to go to the previous file; on failure (start of list), wrap to the last item.
      success = pcall(vim.cmd, "cpfile")
      if not success then
        vim.cmd("clast")
      end
    end
    return
  end

  -- direction: 1 for next, -1 for previous
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs < 2 then
    return
  end
  local bufnrs = vim.tbl_map(function(b)
    return b.bufnr
  end, bufs)
  local current_idx = vim.fn.index(bufnrs, vim.api.nvim_get_current_buf())

  for i = 1, #bufnrs - 1 do
    local offset = i * direction
    -- The `+ #bufnrs` handles potential negative results for the 'previous' case
    local next_idx = (current_idx + offset + #bufnrs) % #bufnrs
    local next_bufnr = bufnrs[next_idx + 1]

    if vim.fn.bufwinnr(next_bufnr) == -1 then
      vim.api.nvim_set_current_buf(next_bufnr)
      return
    end
  end
end

vim.keymap.set("n", "<C-n>", function()
  BufNextPrev(1)
end, {
  desc = "Next buffer",
})
vim.keymap.set("n", "<C-p>", function()
  BufNextPrev(-1)
end, {
  desc = "Previous buffer",
})
vim.keymap.set("n", "<leader>bd", ":bp | bd# <cr>", { desc = "Close current buffer" })

-- vim.keymap.set('n', ',,', ':bp<cr>')
-- vim.keymap.set('v', "'y", '"+y')

vim.keymap.set("i", "jj", "<Esc>", { silent = true })

vim.keymap.set("i", "<C-f>", "<C-o>l")
vim.keymap.set("i", "<C-b>", "<C-o>h")
vim.keymap.set("i", "<C-n>", "<C-o>j")
vim.keymap.set("i", "<C-p>", "<C-o>k")

-- cycle through panes with C-]
vim.keymap.set("t", "<C-]>", "<C-\\><C-N><C-w>w")
vim.keymap.set("i", "<C-]>", "<C-\\><C-N><C-w>wa")
vim.keymap.set("n", "<C-]>", "<C-w>wa")

-- clear current input and go back
vim.keymap.set("n", "<C-BS>", "<C-w>wa<C-c><C-\\><C-N><C-w>w")

vim.keymap.set("t", "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<A-k>", "<C-\\<C-N><C-w>k")
vim.keymap.set("t", "<A-l>", "<C-\\<C-N><C-w>l")
vim.keymap.set("i", "<A-h>", "<C-\\<C-N><C-w>h")
vim.keymap.set("i", "<A-j>", "<C-\\<C-N><C-w>j")
vim.keymap.set("i", "<A-k>", "<C-\\<C-N><C-w>k")
vim.keymap.set("i", "<A-l>", "<C-\\<C-N><C-w>l")
vim.keymap.set("n", "<A-h>", "<C-w>h")

vim.keymap.set("i", "<C-g>", function()
  require("util.openrouter").complete({ mode = "ghost_text" })
end, { desc = "OpenRouter complete (ghost text preview)" })

vim.keymap.set("i", "<A-g>", function()
  require("util.openrouter").complete({ mode = "direct" })
end, { desc = "OpenRouter direct insert" })

vim.keymap.set("i", "<Tab>", function()
  if require("util.openrouter").has_suggestion() then
    require("util.openrouter").accept()
    return ""
  end
  return "<Tab>"
end, { expr = true, desc = "Accept AI completion or Tab" })

vim.keymap.set("i", "<C-y>", function()
  if require("util.openrouter").has_suggestion() then
    require("util.openrouter").accept()
  end
end, { desc = "Accept AI completion" })

vim.keymap.set("i", "<C-e>", function()
  if require("util.openrouter").has_suggestion() then
    require("util.openrouter").dismiss()
  end
end, { desc = "Dismiss AI completion" })
