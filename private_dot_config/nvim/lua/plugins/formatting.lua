-- PHPの整形をLaravel Pintに統一する。
--
-- LazyVimのlang.php extraは既定でphp_cs_fixer（整形）とphpcs（lint）を使うが、
-- Laravelプロジェクトの規約はPintであり、書式が衝突して保存のたびに差分が出る。
-- JS/TSはformatting.prettier extraが有効で、conformがプロジェクトの
-- node_modules/.bin/prettierを自動で拾うため、ここでの設定は不要。
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- conform同梱のpintはプロジェクトのvendor/bin/pintを自動で探し、
      -- 見つからなければグローバルのpintにフォールバックする
      opts.formatters_by_ft.php = { "pint" }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- phpcsは既定でPEAR標準を見るためLaravelのコードに大量の警告を出す。
      -- 整形はPintに任せ、PHPのlintは行わない。
      opts.linters_by_ft.php = {}
    end,
  },
}
