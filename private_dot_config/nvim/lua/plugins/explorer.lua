return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        -- ファイルを開いてもツリーを閉じない（VSCode 風に左ペイン常駐）
        explorer = {
          auto_close = false,
          jump = { close = false },
        },
      },
    },
  },
  -- 起動時に snacks.explorer を開く。<leader>e のトグルは LazyVim 標準のまま。
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        require("snacks").explorer()
        -- フォーカスはエディタ側に戻す
        vim.schedule(function()
          vim.cmd("wincmd p")
        end)
      end,
    })
  end,
}
