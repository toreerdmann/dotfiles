local M = {
  model = "deepseek/deepseek-chat",
  mode = "ghost_text", -- "ghost_text" (preview with Tab/C-y accept) or "direct" (instant insert)
}

local ns_id = vim.api.nvim_create_namespace("openrouter_ghost_text")
local current_suggestion = nil
local active_job = nil

local function get_api_key()
  local key = os.getenv("OPENROUTER_API_KEY")
  if key and key ~= "" then
    return key
  end
  local handle = io.popen("fish -c 'echo $OPENROUTER_API_KEY'")
  if not handle then
    return nil
  end
  key = handle:read("*a"):gsub("%s+", "")
  handle:close()
  if key == "" then
    return nil
  end
  vim.env.OPENROUTER_API_KEY = key
  return key
end

local function clean_code(text)
  if not text then
    return ""
  end
  local cleaned = text
  -- Strip markdown code fences if wrapped
  if cleaned:find("```") then
    local first = cleaned:find("```")
    local start = cleaned:find("\n", first)
    start = start and (start + 1) or (first + 3)
    local last = cleaned:find("```", start) or (#cleaned + 1)
    cleaned = cleaned:sub(start, last - 1)
  end
  return vim.trim(cleaned)
end

function M.dismiss(cancel_job)
  if cancel_job and active_job then
    pcall(function()
      active_job:shutdown()
    end)
    active_job = nil
  end
  if current_suggestion and vim.api.nvim_buf_is_valid(current_suggestion.bufnr) then
    vim.api.nvim_buf_clear_namespace(current_suggestion.bufnr, ns_id, 0, -1)
  end
  current_suggestion = nil
end

function M.has_suggestion()
  return current_suggestion ~= nil and #current_suggestion.lines > 0
end

function M.accept()
  if not current_suggestion or #current_suggestion.lines == 0 then
    return false
  end

  local s = current_suggestion
  M.dismiss(true)

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(s.bufnr) then
      return
    end

    local row, col = s.row, s.col
    local lines = s.lines

    vim.api.nvim_buf_set_text(s.bufnr, row - 1, col, row - 1, col, lines)

    -- Move cursor to the end of inserted text
    local new_row = row + #lines - 1
    local new_col
    if #lines == 1 then
      new_col = col + #lines[1]
    else
      new_col = #lines[#lines]
    end
    vim.api.nvim_win_set_cursor(0, { new_row, new_col })
  end)
  return true
end

-- Auto-dismiss when leaving insert mode or switching buffers
local group = vim.api.nvim_create_augroup("OpenRouterGhostText", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
  group = group,
  callback = function()
    M.dismiss(true)
  end,
})

local function get_other_buffers_context(current_bufnr)
  local snippets = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_bufnr and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
      if name ~= "" then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, 30, false)
        if #lines > 0 then
          table.insert(
            snippets,
            string.format("File: %s\n```%s\n%s\n```", name, vim.bo[buf].filetype, table.concat(lines, "\n"))
          )
        end
      end
      if #snippets >= 2 then
        break
      end
    end
  end
  if #snippets > 0 then
    return "RELATED OPEN FILES:\n" .. table.concat(snippets, "\n\n") .. "\n\n"
  end
  return ""
end

function M.complete(opts)
  opts = opts or {}
  local current_mode = opts.mode or M.mode or "ghost_text"

  M.dismiss(true)

  local api_key = get_api_key()
  if not api_key then
    vim.notify("OPENROUTER_API_KEY not set", vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local filetype = vim.bo[bufnr].filetype
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")

  -- Split current file with capped context window (last 150 lines prefix, next 60 lines suffix)
  local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local start_prefix = math.max(1, row - 150)
  local prefix_lines = {}
  for i = start_prefix, row - 1 do
    table.insert(prefix_lines, all_lines[i] or "")
  end
  local cur_line = all_lines[row] or ""
  local cur_prefix = cur_line:sub(1, col)
  local cur_suffix = cur_line:sub(col + 1)
  table.insert(prefix_lines, cur_prefix)
  local prefix_text = table.concat(prefix_lines, "\n")

  local end_suffix = math.min(#all_lines, row + 60)
  local suffix_lines = { cur_suffix }
  for i = row + 1, end_suffix do
    table.insert(suffix_lines, all_lines[i] or "")
  end
  local suffix_text = table.concat(suffix_lines, "\n")

  local other_context = get_other_buffers_context(bufnr)

  vim.notify("OpenRouter: thinking…", vim.log.levels.INFO)

  local user_prompt = string.format(
    "%sCURRENT FILE: %s (type: %s)\n\n<PREFIX>\n%s\n<CURSOR>\n<SUFFIX>\n%s\n\nProvide ONLY the code that belongs directly between <PREFIX> and <SUFFIX> at <CURSOR>. Do NOT repeat function signatures or existing brackets.",
    other_context,
    filename,
    filetype,
    prefix_text,
    suffix_text
  )

  local plenary_job = require("plenary.job")
  active_job = plenary_job:new({
    command = "curl",
    args = {
      "-s",
      "https://openrouter.ai/api/v1/chat/completions",
      "-H",
      "Content-Type: application/json",
      "-H",
      "Authorization: Bearer " .. api_key,
      "-d",
      vim.fn.json_encode({
        model = M.model,
        max_tokens = 150,
        temperature = 0,
        messages = {
          {
            role = "system",
            content = "You are a code completion engine. Return ONLY the code to fill in at <CURSOR>. Do NOT write conversational explanations. Do NOT repeat code from prefix or suffix.",
          },
          {
            role = "user",
            content = user_prompt,
          },
        },
      }),
    },
    on_exit = function(j, return_val)
      vim.schedule(function()
        active_job = nil
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end

        if return_val ~= 0 then
          vim.notify("OpenRouter: request failed", vim.log.levels.ERROR)
          return
        end

        local raw = table.concat(j:result(), "\n")
        local first_brace = raw:find("{")
        if not first_brace then
          vim.notify("OpenRouter: empty completion", vim.log.levels.WARN)
          return
        end

        local ok, decoded = pcall(vim.fn.json_decode, raw:sub(first_brace))
        if not ok or not decoded or not decoded.choices or #decoded.choices == 0 then
          vim.notify("OpenRouter: bad response", vim.log.levels.ERROR)
          return
        end

        local msg = decoded.choices[1].message
        local raw_content = (msg and msg.content) or ""
        local clean_text = clean_code(raw_content)
        if clean_text == "" then
          vim.notify("OpenRouter: empty completion", vim.log.levels.WARN)
          return
        end

        local lines = vim.split(clean_text, "\n")

        if current_mode == "direct" then
          -- Direct mode: insert directly into buffer at cursor
          vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, lines)
          local new_row = row + #lines - 1
          local new_col = (#lines == 1) and (col + #lines[1]) or #lines[#lines]
          vim.api.nvim_win_set_cursor(0, { new_row, new_col })
        else
          -- Ghost text mode: render full multi-line ghost text preview
          current_suggestion = {
            bufnr = bufnr,
            row = row,
            col = col,
            lines = lines,
          }

          local virt_lines = {}
          if #lines > 1 then
            for i = 2, #lines do
              table.insert(virt_lines, { { lines[i], "Comment" } })
            end
          end

          vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, col, {
            virt_text = { { lines[1] or "", "Comment" } },
            virt_text_pos = "inline",
            virt_lines = #virt_lines > 0 and virt_lines or nil,
            hl_mode = "combine",
          })
        end
      end)
    end,
  })

  active_job:start()
end

return M
