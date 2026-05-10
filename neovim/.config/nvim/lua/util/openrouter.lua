local M = {}

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

local function extract_code(text)
  local first = text:find("```")
  if not first then
    return vim.trim(text)
  end
  local start = text:find("\n", first)
  start = start and start + 1 or first + 3
  local last = text:find("```", start) or #text + 1
  return vim.trim(text:sub(start, last - 1))
end

function M.complete()
  local api_key = get_api_key()
  if not api_key then
    vim.notify("OPENROUTER_API_KEY not set", vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

  vim.notify("OpenRouter: thinking…", vim.log.levels.INFO)

  require("plenary.job")
    :new({
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
          model = "deepseek/deepseek-v4-flash",
          messages = {
            {
              role = "system",
              content = "You are a code completion tool. Provide ONLY the raw code to insert at the cursor. No conversation. No markdown blocks.",
            },
            {
              role = "user",
              content = "FILE:\n" .. content .. "\n\nProvide code for row " .. row .. " col " .. col,
            },
          },
          temperature = 0,
        }),
      },
      on_exit = function(j, return_val)
        local raw = table.concat(j:result(), "\n")
        vim.schedule(function()
          if return_val ~= 0 then
            vim.notify("OpenRouter: curl failed", vim.log.levels.ERROR)
            return
          end
          local ok, decoded = pcall(vim.fn.json_decode, raw)
          if not ok or not decoded or not decoded.choices then
            vim.notify("OpenRouter: bad response — " .. raw, vim.log.levels.ERROR)
            return
          end
          local text = extract_code(decoded.choices[1].message.content)
          if text == "" then
            vim.notify("OpenRouter: empty completion", vim.log.levels.WARN)
            return
          end
          vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, vim.split(text, "\n"))
        end)
      end,
    })
    :start()
end

return M
