return {
  {
    "editor-code-assistant/eca-nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("eca").setup({
        -- Optional configuration here
      })
    end,
  },
  { "ggml-org/llama.vim" },
  { "zbirenbaum/copilot.lua", enabled = false },
}
