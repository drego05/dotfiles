local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    yaml = { "prettier" },
    json = { "prettier" },
    lua = { "stylua" },
    python = { "black" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    markdown = { "prettier" },
  },

  -- Format on save
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },

  -- Manual format keybinding
  vim.keymap.set({ "n", "v" }, "<leader>f", function()
    conform.format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 500,
    })
  end, { desc = "Format file or range" }),
})
