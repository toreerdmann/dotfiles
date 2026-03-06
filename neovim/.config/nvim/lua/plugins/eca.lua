return {
  "editor-code-assistant/eca-nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("eca").setup({
      -- Optional configuration here
    })
  end,
}
