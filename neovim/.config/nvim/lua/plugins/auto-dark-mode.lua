return {
  "f-person/auto-dark-mode.nvim",
  enabled = function()
    return not vim.env.CODESPACES and not vim.env.SSH_CLIENT and not vim.env.SSH_TTY
  end,
  opts = {

    update_interval = 1000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd("colorscheme catppuccin-mocha")
      -- Update git config for delta
      vim.fn.system("git config --global delta.features catppuccin-mocha")
      -- Reload tmux
      -- local home = os.getenv("HOME")
      -- vim.fn.system("tmux set-option -g @catppuccin_flavor_override mocha")
      -- vim.fn.system("tmux source-file " .. home .. "/.tmux.conf > /dev/null 2>&1 || true")
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd("colorscheme catppuccin-latte")
      -- Update git config for delta
      vim.fn.system("git config --global delta.features catppuccin-latte")
      -- Reload tmux
      local home = os.getenv("HOME")
      -- vim.fn.system("tmux set-option -g @catppuccin_flavor_override latte")
      -- vim.fn.system("tmux source-file " .. home .. "/.tmux.conf > /dev/null 2>&1 || true")
    end,
  },
}
