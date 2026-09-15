-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- nvm is lazy-loaded in zsh (see dotfiles rc/pluginconfig/nvm.zsh), so `node`
-- may be missing from PATH in a shell that hasn't touched node/npm yet. That
-- silently breaks node-based LSP servers (vtsls, pyright-langserver). Resolve
-- the installed node bin dir directly instead of relying on the shell stub.
if vim.fn.executable("node") == 0 then
  local versions_dir = (vim.env.NVM_DIR or (vim.env.HOME .. "/.nvm")) .. "/versions/node"
  local versions = vim.fn.isdirectory(versions_dir) == 1 and vim.fn.readdir(versions_dir) or {}
  table.sort(versions)
  local latest = versions[#versions]
  if latest then
    vim.env.PATH = versions_dir .. "/" .. latest .. "/bin:" .. vim.env.PATH
  end
end
