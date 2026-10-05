return {
  "martindur/zdiff.nvim",
  cmd = "Zdiff",
  keys = {
    { "<leader>zd", "<cmd>Zdiff<cr>", desc = "Zdiff (uncommitted)" },
    { "<leader>zD", "<cmd>Zdiff development<cr>", desc = "Zdiff (vs dev)" },
  },
  opts = {},
  enabled = true,
}
