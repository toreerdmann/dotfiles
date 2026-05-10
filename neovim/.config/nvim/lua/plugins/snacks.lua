return {
  "snacks.nvim",
  keys = {
    { "<leader>ff", function() LazyVim.pick("files", { root = false })() end, desc = "Find Files (cwd)" },
    { "<leader>fF", function() LazyVim.pick("files")() end, desc = "Find Files (Root Dir)" },
  },
  opts = {
    indent = { enabled = false },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    toggle = { map = LazyVim.safe_keymap_set },
    words = { enabled = true },
  },
}
