return {
  "snacks.nvim",
  keys = {
    { "<leader>ff", function() LazyVim.pick("files", { root = false })() end, desc = "Find Files (cwd)" },
    { "<leader>fF", function() LazyVim.pick("files")() end, desc = "Find Files (Root Dir)" },
    { "<leader>fa", function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = "Find Files (incl. hidden/ignored)" },
    { "<leader>sa", function() Snacks.picker.grep({ hidden = true, ignored = true }) end, desc = "Grep (incl. hidden/ignored)" },
  },
  opts = {
    indent = { enabled = false },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = {
      sources = {
        explorer = {
          hidden = true, -- show dotfiles
          ignored = true, -- show gitignored files
        },
      },
    },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    toggle = { map = LazyVim.safe_keymap_set },
    words = { enabled = true },
  },
}
