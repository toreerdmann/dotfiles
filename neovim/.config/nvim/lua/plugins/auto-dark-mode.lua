local function get_theme_config()
  local home = vim.env.HOME or os.getenv("HOME")
  local path = home .. "/.config/theme/current.json"
  local f = io.open(path, "r")
  if not f then
    return {
      dark = "catppuccin-mocha",
      light = "catppuccin-latte",
      delta_dark = "catppuccin-mocha",
      delta_light = "catppuccin-latte",
    }
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and type(data) == "table" then
    return {
      dark = (data.dark and data.dark.nvim) or "catppuccin-mocha",
      light = (data.light and data.light.nvim) or "catppuccin-latte",
      delta_dark = (data.dark and data.dark.delta) or "catppuccin-mocha",
      delta_light = (data.light and data.light.delta) or "catppuccin-latte",
    }
  end
  return {
    dark = "catppuccin-mocha",
    light = "catppuccin-latte",
    delta_dark = "catppuccin-mocha",
    delta_light = "catppuccin-latte",
  }
end

local function apply_theme(mode)
  local cfg = get_theme_config()
  local is_dark = (mode == "dark")
  local target_scheme = is_dark and cfg.dark or cfg.light
  local delta_theme = is_dark and cfg.delta_dark or cfg.delta_light

  vim.api.nvim_set_option_value("background", mode, {})
  if vim.g.colors_name ~= target_scheme then
    pcall(vim.cmd, "colorscheme " .. target_scheme)
  end

  if delta_theme and delta_theme ~= "" then
    vim.fn.system("git config --global delta.features " .. delta_theme)
  end
end

return {
  "f-person/auto-dark-mode.nvim",
  enabled = function()
    return not vim.env.CODESPACES and not vim.env.SSH_CLIENT and not vim.env.SSH_TTY
  end,
  init = function()
    -- Sync colorscheme when Neovim regains focus in case theme was changed from terminal
    vim.api.nvim_create_autocmd("FocusGained", {
      group = vim.api.nvim_create_augroup("ThemeAutoReload", { clear = true }),
      callback = function()
        local bg = vim.o.background or "dark"
        local cfg = get_theme_config()
        local target = (bg == "light") and cfg.light or cfg.dark
        if vim.g.colors_name ~= target then
          pcall(vim.cmd, "colorscheme " .. target)
        end
      end,
    })
  end,
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      apply_theme("dark")
    end,
    set_light_mode = function()
      apply_theme("light")
    end,
  },
}
