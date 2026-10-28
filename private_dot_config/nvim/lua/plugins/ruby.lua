-- Ruby / Rails（Hotwire）の補足設定。lang.ruby / lang.tailwind extra と併用する。
--
-- lang.ruby extraのneotestアダプタはRSpec用のみで、Railsの既定であるMinitestを
-- エディタから実行できないため、neotest-minitestを足す。
-- ERB向けにHerb（HTML+ERBの診断・整形）とStimulusの言語サーバーも有効にする。
-- どちらもnpm配布のため、Masonでのインストール時にnpmがPATHに必要
-- （nvmは遅延読み込みなので、初回は起動元のシェルでnode -vを一度実行しておく）。
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "zidhuss/neotest-minitest" },
    opts = {
      adapters = {
        ["neotest-minitest"] = {
          -- Gemfileがあれば既定どおりbundle経由、なければ素のrubyで流す
          -- （~/practice/ruby-basics のような lib/ + test/ 構成の練習用ディレクトリ向け）
          test_cmd = function()
            if vim.fn.filereadable(vim.fn.getcwd() .. "/Gemfile") == 1 then
              return { "bundle", "exec", "ruby", "-Itest" }
            end
            return { "ruby", "-Ilib", "-Itest" }
          end,
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- 既定ではhtml（stimulus_lsはblade/phpも）に付き、Laravelの案件でも起動してしまう。
        -- RailsのビューであるERBに限定する。
        herb_ls = { filetypes = { "eruby" } },
        stimulus_ls = { filetypes = { "eruby" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "embedded_template" } },
  },
}
