return {
  "saghen/blink.cmp",
  config = function()
    require("blink.cmp").setup({
      sources = {
        -- Add 'pyrefly' to your list of enabled providers
        default = { "lsp", "path", "snippets", "buffer" },
      },
    })
  end,
}
