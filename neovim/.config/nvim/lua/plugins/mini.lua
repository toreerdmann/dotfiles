return {
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
}
