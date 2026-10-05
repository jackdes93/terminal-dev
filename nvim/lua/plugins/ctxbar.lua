-- ctxbar: context/usage Claude Code trên lualine + :ClaudeUsage
return {
  {
    dir = "~/Documents/RDP/SECRECT_TOOL/context-bar/nvim",
    name = "ctxbar",
    event = "VeryLazy",
    opts = { cmd = vim.fn.expand("~/.local/bin/ctxbar") },
    keys = { { "<leader>cu", "<cmd>ClaudeUsage<cr>", desc = "Claude usage" } },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, 1, require("ctxbar").lualine)
    end,
  },
}
