return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd("colorscheme catppuccin-mocha")
      -- Update git config for delta
      vim.fn.system("git config --global delta.features catppuccin-mocha")
      -- Reload tmux if in a tmux session
      if os.getenv("TMUX") then
        vim.fn.system("tmux source-file ~/.tmux.conf")
      end
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd("colorscheme catppuccin-latte")
      -- Update git config for delta
      vim.fn.system("git config --global delta.features catppuccin-latte")
      -- Reload tmux if in a tmux session
      if os.getenv("TMUX") then
        vim.fn.system("tmux source-file ~/.tmux.conf")
      end
    end,
  },
}
