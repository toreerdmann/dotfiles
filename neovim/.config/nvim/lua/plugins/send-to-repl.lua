return {
  "toreerdmann/send-to-repl.nvim",
  cmd = {
    "SendToReplWith",
    "SendToReplCmd",
    "SendToReplCommand",
    "SendToReplStart",
    "SendToReplToggle",
    "SendToReplRestart",
    "SendToReplClear",
    "SendToReplInterrupt",
    "SendToReplSend",
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
      "<leader>c",
      function()
        require("send-to-repl").send_cell()
      end,
      desc = "Send cell to REPL",
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
      "<leader>rf",
      function()
        require("send-to-repl").send_file()
      end,
      desc = "Send file to REPL",
    },
    {
      "<leader>rt",
      function()
        require("send-to-repl").toggle_repl()
      end,
      desc = "Toggle REPL window",
    },
    {
      "<leader>rr",
      function()
        require("send-to-repl").restart_repl()
      end,
      desc = "Restart REPL",
    },
    {
      "<leader>rw",
      function()
        require("send-to-repl").start_repl_with()
      end,
      desc = "Start REPL with packages",
    },
    {
      "<leader>rc",
      function()
        require("send-to-repl").start_repl_cmd()
      end,
      desc = "Start REPL with custom command",
    },
    {
      "<leader>rx",
      function()
        require("send-to-repl").clear()
      end,
      desc = "Clear REPL screen",
    },
    {
      "<leader>ri",
      function()
        require("send-to-repl").interrupt()
      end,
      desc = "Interrupt REPL (Ctrl-C)",
    },
    {
      "gxc",
      function()
        require("send-to-repl").send_operator()
      end,
      desc = "Send motion to REPL",
    },
  },
  opts = {
    layout = {
      split = "vertical", -- "vertical" | "horizontal" | "tab"
      size = 0.4, -- 40% split width/height
    },
  },
}
