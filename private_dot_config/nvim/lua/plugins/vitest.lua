-- TypeScript（Vitest）のテストを neotest から実行する。
--
-- test.core extra が入れるアダプタは言語 extra 経由のもの（PHP・Python・Ruby）だけで、
-- lang.typescript extra はテストアダプタを足さない。drasewkit.dev（Vitest +
-- @cloudflare/vitest-plugin）のテストを <leader>tr などで動かすために追加する。
-- vitest はプロジェクトの node_modules/.bin/vitest が使われ、vitest.config.ts の
-- プラグイン（Workers ランタイムでの実行）もそのまま効く。
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "marilari88/neotest-vitest" },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
      },
    },
  },
}
