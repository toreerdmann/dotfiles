return {
  "martindur/zdiff.nvim",
  cmd = "Zdiff",
  keys = {
    { "<leader>zd", "<cmd>Zdiff<cr>", desc = "Zdiff (uncommitted)" },
    { "<leader>zD", "<cmd>Zdiff development<cr>", desc = "Zdiff (vs dev)" },
  },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "zdiff",
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }
        vim.keymap.set("n", "<CR>", "<cmd>ZdiffOpen<cr>", opts)
        vim.keymap.set("n", "<Tab>", "<cmd>ZdiffToggle<cr>", opts)
        vim.keymap.set("n", "R", "<cmd>ZdiffRefresh<cr>", opts)
        vim.keymap.set("n", "q", "<cmd>bdelete<cr>", opts)
      end,
    })
  end,
  enabled = true,
}
