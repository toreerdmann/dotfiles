return {
  "toreerdmann/send-to-repl.nvim",
  lazy = true,
  opts = {
    repls = {
      r = {
        cmd = "R",
        args = { "--no-save", "--quiet" },
      },
    },
  },
  keys = {
    {
      "<leader>l",
      function()
        require("send-to-repl").send_line()
      end,
      desc = "Send line to REPL",
    },
    {
      "<leader>p",
      function()
        require("send-to-repl").send_word()
      end,
      desc = "Send word to REPL",
    },
    {
      "<leader><CR>",
      function()
        require("send-to-repl").send_paragraph()
      end,
      desc = "Send paragraph to REPL",
    },
    {
      "<leader><CR>",
      function()
        require("send-to-repl").send_visual()
      end,
      mode = "v",
      desc = "Send selection to REPL",
    },
    {
      "<C-]>",
      function()
        require("send-to-repl").toggle_repl()
      end,
      mode = { "n", "t" },
      desc = "Jump between left and right pane",
    },
  },
}
