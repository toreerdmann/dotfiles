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

local function get_file_symbols(bufnr, lines)
  -- 1. Query Pyrefly / active LSP for document symbols
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients > 0 then
    local res = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
    }, 150)
    if res then
      local symbols = {}
      for _, response in pairs(res) do
        if response.result and #response.result > 0 then
          local function collect_syms(list, indent)
            for _, item in ipairs(list) do
              -- Kind 5=Class, 6=Method, 12=Function, 11=Interface, 23=Struct
              if item.kind == 5 or item.kind == 6 or item.kind == 12 or item.kind == 11 or item.kind == 23 then
                local desc = (item.kind == 5 and "class " or "def ") .. item.name .. (item.detail and (" " .. item.detail) or "")
                table.insert(symbols, string.rep("  ", indent) .. desc)
              end
              if item.children then
                collect_syms(item.children, indent + 1)
              end
            end
          end
          collect_syms(response.result, 0)
        end
      end
      if #symbols > 0 then
        return "CURRENT FILE OUTLINE (from LSP):\n" .. table.concat(symbols, "\n") .. "\n\n"
      end
    end
  end

  -- 2. Fallback outline extraction (Python / C / JS / TS)
  local symbols = {}
  for _, line in ipairs(lines) do
    if line:match("^%s*class%s+") or line:match("^%s*def%s+") or line:match("^%s*async%s+def%s+") then
      local trimmed = (line:gsub(":%s*$", ""))
      table.insert(symbols, trimmed)
    elseif line:match("^%s*[%w_]+%s+[%w_]+%s*%b()") and not line:match("^%s*if%s") and not line:match("^%s*while%s") then
      table.insert(symbols, vim.trim(line:gsub("%s*{.*$", "")))
    end
  end
  if #symbols > 0 then
    return "CURRENT FILE OUTLINE:\n" .. table.concat(symbols, "\n") .. "\n\n"
  end
  return ""
end

local function get_local_imports_context(bufnr, lines)
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local file_dir = vim.fs.dirname(file_path) or "."
  local cwd = vim.fn.getcwd()
  local imported_context = {}
  local seen = {}

  for _, line in ipairs(lines) do
    -- Python imports (from ... import ... or import ...)
    local py_mod = line:match("^%s*from%s+([%w_%.]+)%s+import") or line:match("^%s*import%s+([%w_%.]+)")
    if py_mod then
      local rel = py_mod:gsub("^%.", ""):gsub("%.", "/")
      local candidates = {
        file_dir .. "/" .. rel .. ".py",
        file_dir .. "/" .. rel .. "/__init__.py",
        cwd .. "/" .. rel .. ".py",
        cwd .. "/" .. rel .. "/__init__.py",
      }
      for _, cand in ipairs(candidates) do
        if vim.uv.fs_stat(cand) and not seen[cand] then
          seen[cand] = true
          local f = io.open(cand, "r")
          if f then
            local content = f:read("*a")
            f:close()
            local flines = vim.split(content, "\n")
            local syms = {}
            for _, fl in ipairs(flines) do
              if fl:match("^%s*class%s+") or fl:match("^%s*def%s+") or fl:match("^%s*async%s+def%s+") then
                table.insert(syms, (fl:gsub(":%s*$", "")))
              end
            end
            local rel_name = vim.fn.fnamemodify(cand, ":.")
            if #syms > 0 then
              table.insert(imported_context, string.format("IMPORTED MODULE (%s):\n%s", rel_name, table.concat(syms, "\n")))
            else
              local snippet = table.concat(vim.list_slice(flines, 1, math.min(#flines, 25)), "\n")
              table.insert(imported_context, string.format("IMPORTED MODULE (%s):\n%s", rel_name, snippet))
            end
          end
          break
        end
      end
    end

    -- C/C++ includes (#include "...")
    local c_header = line:match('^%s*#include%s*"([^"]+)"')
    if c_header then
      local cand = file_dir .. "/" .. c_header
      if vim.uv.fs_stat(cand) and not seen[cand] then
        seen[cand] = true
        local f = io.open(cand, "r")
        if f then
          local content = f:read("*a")
          f:close()
          table.insert(imported_context, string.format("HEADER (%s):\n%s", c_header, content))
        end
      end
    end
    if #imported_context >= 3 then
      break
    end
  end

  if #imported_context > 0 then
    return "IMPORTED MODULES / DEFINITIONS:\n" .. table.concat(imported_context, "\n\n") .. "\n\n"
  end
  return ""
end

local function get_lsp_diagnostics_context(bufnr, row)
  local diags = vim.diagnostic.get(bufnr, { lnum = row - 1 })
  if #diags > 0 then
    local msgs = {}
    for _, d in ipairs(diags) do
      table.insert(msgs, string.format("- Line %d: %s", d.lnum + 1, d.message))
    end
    return "LSP DIAGNOSTICS AT CURSOR:\n" .. table.concat(msgs, "\n") .. "\n\n"
  end
  return ""
end

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

  local symbols_context = get_file_symbols(bufnr, all_lines)
  local imports_context = get_local_imports_context(bufnr, all_lines)
  local diag_context = get_lsp_diagnostics_context(bufnr, row)
  local other_buffers = get_other_buffers_context(bufnr)

  local extra_context = symbols_context .. imports_context .. diag_context .. other_buffers

  local start_time = vim.uv.now()
  vim.notify("Thinking…", vim.log.levels.INFO, { title = "OpenRouter" })

  local user_prompt = string.format(
    "%sCURRENT FILE: %s (type: %s)\n\n<PREFIX>\n%s\n<CURSOR>\n<SUFFIX>\n%s\n\nProvide ONLY the code that belongs directly between <PREFIX> and <SUFFIX> at <CURSOR>. Do NOT repeat function signatures or existing brackets.",
    extra_context,
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
        local duration_ms = vim.uv.now() - start_time

        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end

        if return_val ~= 0 then
          vim.notify("Request failed (" .. duration_ms .. "ms)", vim.log.levels.ERROR, { title = "OpenRouter" })
          return
        end

        local raw = table.concat(j:result(), "\n")
        local first_brace = raw:find("{")
        if not first_brace then
          vim.notify("Empty response payload", vim.log.levels.WARN, { title = "OpenRouter" })
          return
        end

        local ok, decoded = pcall(vim.fn.json_decode, raw:sub(first_brace))
        if not ok or not decoded or not decoded.choices or #decoded.choices == 0 then
          vim.notify("Bad response JSON", vim.log.levels.ERROR, { title = "OpenRouter" })
          return
        end

        local msg = decoded.choices[1].message
        local raw_content = (msg and msg.content) or ""
        local clean_text = clean_code(raw_content)
        if clean_text == "" then
          vim.notify("Empty completion (" .. duration_ms .. "ms)", vim.log.levels.WARN, { title = "OpenRouter" })
          return
        end

        -- Store last request telemetry in memory
        M.last_request = {
          timestamp = os.date("%Y-%m-%d %H:%M:%S"),
          model = M.model,
          mode = current_mode,
          route = "⚡ Fast Path (Direct 1-Hop)",
          context_summary = {
            has_symbols = symbols_context ~= "",
            has_imports = imports_context ~= "",
            has_diagnostics = diag_context ~= "",
            has_other_buffers = other_buffers ~= "",
          },
          filename = filename,
          duration_ms = duration_ms,
          usage = decoded.usage,
          prompt = user_prompt,
          completion = clean_text,
        }

        local usage = decoded.usage or {}
        local token_msg = usage.completion_tokens and string.format("⚡ %dms (%d tokens)", duration_ms, usage.completion_tokens) or string.format("⚡ %dms", duration_ms)
        vim.notify(token_msg, vim.log.levels.INFO, { title = "OpenRouter" })

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

function M.show_log()
  if not M.last_request then
    vim.notify("No recent OpenRouter requests in this session", vim.log.levels.WARN, { title = "OpenRouter" })
    return
  end

  local r = M.last_request
  local lines = {
    "# OpenRouter Inspection Log",
    "",
    string.format("- **Timestamp**: `%s`", r.timestamp),
    string.format("- **Route Path**: `%s`", r.route or "Fast Path"),
    string.format("- **Mode**: `%s`", r.mode or "ghost_text"),
    string.format("- **Model**: `%s`", r.model),
    string.format("- **Target File**: `%s`", r.filename),
    string.format("- **Latency**: `%d ms`", r.duration_ms),
  }

  if r.context_summary then
    local ctx_items = {}
    if r.context_summary.has_symbols then table.insert(ctx_items, "LSP/File Outline") end
    if r.context_summary.has_imports then table.insert(ctx_items, "Local Imported Modules") end
    if r.context_summary.has_diagnostics then table.insert(ctx_items, "LSP Diagnostics") end
    if r.context_summary.has_other_buffers then table.insert(ctx_items, "Active Open Buffers") end
    local ctx_str = #ctx_items > 0 and table.concat(ctx_items, ", ") or "None (Current buffer only)"
    table.insert(lines, string.format("- **Injected Context Sources**: `%s`", ctx_str))
  end

  if r.usage then
    table.insert(lines, string.format("- **Prompt Tokens**: `%d`", r.usage.prompt_tokens or 0))
    table.insert(lines, string.format("- **Completion Tokens**: `%d`", r.usage.completion_tokens or 0))
    if r.usage.cost then
      table.insert(lines, string.format("- **Cost**: `$%f`", r.usage.cost))
    end
  end

  table.insert(lines, "")
  table.insert(lines, "## Generated Completion")
  table.insert(lines, "```")
  for _, l in ipairs(vim.split(r.completion, "\n")) do
    table.insert(lines, l)
  end
  table.insert(lines, "```")
  table.insert(lines, "")
  table.insert(lines, "## Prompt & Injected Context")
  table.insert(lines, "```")
  for _, l in ipairs(vim.split(r.prompt, "\n")) do
    table.insert(lines, l)
  end
  table.insert(lines, "```")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(100, vim.o.columns - 4)
  local height = math.min(30, vim.o.lines - 4)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " OpenRouter Inspector [q: close] ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
end

vim.api.nvim_create_user_command("OpenRouterLog", function()
  M.show_log()
end, { desc = "Inspect last OpenRouter prompt, context, and response" })

return M
