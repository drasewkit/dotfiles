local M = {}

-- NB_EDITOR=: / NO_COLOR=1 … nb の対話・色出力を抑止
-- GIT_TERMINAL_PROMPT=0 / ssh BatchMode … auto_sync の git push が
--   認証プロンプトで固まらないようにする（ネット断時は ~5s で失敗し、
--   ノートはローカルに commit 済み。後で `nb sync` で解消できる）
local NB_CMD = table.concat({
  "NB_EDITOR=:",
  "NO_COLOR=1",
  "GIT_TERMINAL_PROMPT=0",
  "GIT_SSH_COMMAND='ssh -oBatchMode=yes -oConnectTimeout=5'",
  "nb",
}, " ")

-- add / grep / list / picker が対象にする「現在 use 中の notebook」のパス
function M.get_nb_dir()
  local output = M.run_cmd("notebooks current --path")
  if output and output[1] and vim.trim(output[1]) ~= "" then
    return vim.trim(output[1])
  end
  return vim.fn.expand("~/src/github.com/drasewkit/nb/home")
end

-- bufferline のノート判定用「全 notebook のルート」($NB_DIR)
function M.get_nb_root()
  return vim.fn.expand("~/src/github.com/drasewkit/nb")
end

function M.run_cmd(args)
  local cmd = NB_CMD .. " " .. args
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return output
end

function M.parse_list_item(line)
  local note_id = line:match("^%[(.-)%]")
  if not note_id then
    return nil
  end

  local is_image = line:match("🌄") ~= nil
  local name
  if is_image then
    name = line:match("%[%d+%]%s*🌄%s*(.+)$")
  else
    name = line:match("%[%d+%]%s*(.+)$")
  end

  if not name then
    return nil
  end

  return {
    note_id = note_id,
    name = vim.trim(name),
    is_image = is_image,
    text = line,
  }
end

-- id -> 絶対パス の対応表を 1 コマンドで取得（プレビューの都度 `nb show` を
-- 叩かずに済ませるため）。`nb list --paths` は `[id] /abs/path.md` 形式。
function M.list_paths()
  local output = M.run_cmd("list --paths --no-color")
  if not output then
    return {}
  end
  local map = {}
  for _, line in ipairs(output) do
    local id, path = line:match("^%[(.-)%]%s+(.+)$")
    if id and path then
      map[id] = vim.trim(path)
    end
  end
  return map
end

function M.list_items()
  local output = M.run_cmd("list --no-color")
  if not output then
    return nil
  end

  local paths = M.list_paths()
  local items = {}
  for _, line in ipairs(output) do
    local item = M.parse_list_item(line)
    if item then
      item.file = paths[item.note_id]
      table.insert(items, item)
    end
  end
  return items
end

function M.get_title(filepath)
  local nb_root = M.get_nb_root()
  if not vim.startswith(filepath, nb_root) then
    return nil
  end

  local file = io.open(filepath, "r")
  if not file then
    return nil
  end

  local first_line = file:read("*l")
  file:close()

  if first_line then
    return first_line:match("^#%s+(.+)")
  end
  return nil
end

function M.get_note_path(note_id)
  local output = M.run_cmd("show --path " .. note_id)
  if output and output[1] then
    return vim.trim(output[1])
  end
  return ""
end

function M.delete_note(note_id)
  local output = M.run_cmd("delete --force " .. note_id)
  return output ~= nil
end

function M.add_note(title)
  local timestamp = os.date("%Y%m%d%H%M%S")
  local note_title = title and title ~= "" and title or
                     os.date("%Y-%m-%d %H:%M:%S")
  local escaped_title = note_title:gsub('"', '\\"')
  local args = string.format('add --no-color --filename "%s.md" '..
                             '--title "%s"', timestamp, escaped_title)

  local output = M.run_cmd(args)
  if not output then
    return nil
  end

  for _, line in ipairs(output) do
    local note_id = line:match("%[(%d+)%]")
    if note_id then
      return note_id
    end
  end
  return nil
end

function M.import_image(image_path, new_filename)
  if not image_path or image_path == "" then
    return nil, "No path provided"
  end

  local cleaned_path = image_path:gsub("^%s*['\"]?", "")
                                  :gsub("['\"]?%s*$", "")
  local expanded_path = vim.fn.expand(cleaned_path)

  if vim.fn.filereadable(expanded_path) == 0 then
    return nil, "File not found: " .. expanded_path
  end

  local final_filename
  if new_filename and new_filename ~= "" then
    if not new_filename:match("%.%w+$") then
      local ext = vim.fn.fnamemodify(expanded_path, ":e")
      new_filename = new_filename .. "." .. ext
    end
    final_filename = new_filename
  else
    final_filename = vim.fn.fnamemodify(expanded_path, ":t")
  end

  local escaped_path = vim.fn.shellescape(expanded_path)
  local args = "import --no-color " .. escaped_path
  if new_filename and new_filename ~= "" then
    args = args .. " " .. vim.fn.shellescape(new_filename)
  end

  local output = M.run_cmd(args)
  if not output then
    return nil, "Import failed"
  end

  for _, line in ipairs(output) do
    local note_id = line:match("%[(%d+)%]")
    if note_id then
      return note_id, final_filename
    end
  end
  return nil, "Could not parse import result"
end

return M
