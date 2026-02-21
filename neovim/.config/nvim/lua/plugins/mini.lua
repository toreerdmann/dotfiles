return {
  { "nvim-mini/mini.ai" },
  {
    "nvim-mini/mini.nvim",
    version = "*",
    config = function()
      local animate = require("mini.animate")
      animate.setup({
        cursor = {
          -- Whether to enable this animation
          enable = true,
          -- Timing of animation (how steps will progress in time)
          timing = animate.gen_timing.cubic({ duration = 20, unit = "total" }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
        },
      })
    end,
  },
  {
    "nvim-mini/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local opts = LazyVim.opts("mini.surround")
      local mappings = {
        { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "x" } },
        { opts.mappings.delete, desc = "Delete Surrounding" },
        { opts.mappings.find, desc = "Find Right Surrounding" },
        { opts.mappings.find_left, desc = "Find Left Surrounding" },
        { opts.mappings.highlight, desc = "Highlight Surrounding" },
        { opts.mappings.replace, desc = "Replace Surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },
}
