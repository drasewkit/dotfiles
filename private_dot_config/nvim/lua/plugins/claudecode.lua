-- ai.claudecode extra の補足設定。
--
-- extra の「ツリーからファイルを Claude に追加」(<leader>as) は ft が
-- NvimTree / neo-tree / oil に限定されており、このリポジトリで常駐させている
-- snacks.explorer（ft = snacks_picker_list）では効かない。
-- claudecode.nvim 本体は snacks_picker_list に対応済みなので、キーだけ足す。
return {
  "coder/claudecode.nvim",
  optional = true,
  keys = {
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "snacks_picker_list" },
    },
  },
}
