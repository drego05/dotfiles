local lint_ok, lint = pcall(require, "lint")
if not lint_ok then
  return
end

lint.linters_by_ft = {
  yaml     = { "yamllint" },
  json     = { "jsonlint" },
  markdown = { "markdownlint" },
}

-- Run linter on save and when entering a buffer
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
