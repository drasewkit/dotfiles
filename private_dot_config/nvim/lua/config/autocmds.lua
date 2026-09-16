-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- nb ノートは日本語＋ローマ字の技術用語が中心で、英語スペルチェックはノイズに
-- なるだけなので markdown / text では無効化する（wrap は LazyVim 標準のまま残す）。
-- vim.schedule で1ティック遅らせているのは、LazyVim 標準の `lazyvim_wrap_spell`
-- (FileType markdown/text で spell=true) との登録順レースを避けるため。
-- 起動時の引数の与え方 (`nvim .` か `nvim file.md` か) によって LazyVim 側の
-- autocmds 読み込みタイミングが変わり、同一 tick 内での定義順が入れ替わって
-- こちらが先に負けることがあった (2026-09-16 に実際に発生・確認済み)。
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_nospell", { clear = true }),
  pattern = { "markdown", "text" },
  callback = function()
    vim.schedule(function()
      vim.opt_local.spell = false
    end)
  end,
})
