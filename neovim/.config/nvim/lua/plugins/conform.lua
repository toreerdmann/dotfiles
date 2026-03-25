return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  opts = {
    formatters_by_ft = {
      python = {
        -- To fix auto-fixable lint errors.
        "ruff_fix",
        -- To run the Ruff formatter.
        "ruff_format",
        -- To organize the imports.
        "ruff_organize_imports",
      },
      toml = { "taplo" },
    },
    formatters = {
      taplo = {
        args = { "format", "-", "--option", "indent_string=    " },
      },
    },
  },
}
