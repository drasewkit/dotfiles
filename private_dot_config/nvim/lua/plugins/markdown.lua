-- lang.markdown extra bundles markdownlint-cli2 as both a linter and a
-- format-on-save fixer. It's too strict for existing docs (MD060 table
-- style etc.), so disable it while keeping preview/render-markdown/marksman.
-- Use opts functions (not plain opts tables) so the list values are
-- actually filtered instead of index-merged with LazyVim's defaults.
return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = vim.tbl_filter(function(linter)
        return linter ~= "markdownlint-cli2"
      end, opts.linters_by_ft.markdown or {})
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      for _, ft in ipairs({ "markdown", "markdown.mdx" }) do
        opts.formatters_by_ft[ft] = vim.tbl_filter(function(formatter)
          return formatter ~= "markdownlint-cli2"
        end, opts.formatters_by_ft[ft] or {})
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "markdownlint-cli2"
      end, opts.ensure_installed or {})
    end,
  },
  -- blink.cmp's buffer source treats unspaced Japanese runs as single words
  -- and keeps popping up past sentences while writing notes (nb), so turn
  -- completion off for prose filetypes. Keeps blink's default conditions.
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      enabled = function()
        return vim.bo.buftype ~= "prompt"
          and vim.b.completion ~= false
          and not vim.tbl_contains({ "markdown", "markdown.mdx", "text" }, vim.bo.filetype)
      end,
    },
  },
}
