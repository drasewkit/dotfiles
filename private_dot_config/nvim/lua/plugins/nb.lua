local function pick_notes()
  local nb = require("config.nb")
  local Snacks = require("snacks")
  local items = nb.list_items()

  if not items or #items == 0 then
    vim.notify("No notes found", vim.log.levels.WARN)
    return
  end

  Snacks.picker({
    title = "nb Notes",
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    preview = function(ctx)
      local item = ctx.item
      if not item.file then
        item.file = nb.get_note_path(item.note_id)
      end
      return Snacks.picker.preview.file(ctx)
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.cmd.edit(item.file or nb.get_note_path(item.note_id))
      end
    end,
    actions = {
      delete_note = function(picker)
        local item = picker:current()
        if item then
          vim.ui.select({ "Yes", "No" }, {
            prompt = "Delete: " .. item.name .. "?",
          }, function(choice)
            if choice == "Yes" then
              if nb.delete_note(item.note_id) then
                vim.notify("Deleted: " .. item.name,
                           vim.log.levels.INFO)
                picker:close()
                pick_notes()
              else
                vim.notify("Failed to delete", vim.log.levels.ERROR)
              end
            end
          end)
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-d>"] = { "delete_note", mode = { "n", "i" },
                        desc = "Delete note" },
        },
      },
    },
  })
end

local function grep_notes()
  local nb = require("config.nb")
  local Snacks = require("snacks")
  -- dirs ではなく cwd を渡す: 結果を notebook からの相対パスで表示（記事は dirs で
  -- ルートからのフルパスになる）。検索範囲は current notebook 配下のみで同じ。
  Snacks.picker.grep({
    cwd = nb.get_nb_dir(),
  })
end

local function add_note()
  local nb = require("config.nb")
  vim.ui.input({ prompt = "Note title (empty for timestamp): " },
    function(title)
      local note_id = nb.add_note(title)
      if note_id then
        local path = nb.get_note_path(note_id)
        if path and path ~= "" then
          vim.cmd.edit(path)
        end
      else
        vim.notify("Failed to add note", vim.log.levels.ERROR)
      end
    end)
end

local function import_image()
  local nb = require("config.nb")
  vim.ui.input({ prompt = "Image path: ", completion = "file" },
    function(image_path)
      if not image_path or image_path == "" then
        return
      end

      vim.ui.input({ prompt = "New filename (empty to keep): " },
        function(new_filename)
          local note_id, result = nb.import_image(image_path,
                                                   new_filename)
          if note_id then
            local filename = result
            local link = string.format("![%s](%s)", filename, filename)
            vim.api.nvim_put({ link }, "c", true, true)
            vim.notify("Imported: " .. filename, vim.log.levels.INFO)
          else
            vim.notify(result or "Failed to import image",
                       vim.log.levels.ERROR)
          end
        end)
    end)
end

local function link_item()
  local nb = require("config.nb")
  local Snacks = require("snacks")
  local items = nb.list_items()

  if not items or #items == 0 then
    vim.notify("No items found", vim.log.levels.WARN)
    return
  end

  Snacks.picker({
    title = "nb Link",
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    preview = function(ctx)
      local item = ctx.item
      if not item.file then
        item.file = nb.get_note_path(item.note_id)
      end
      return Snacks.picker.preview.file(ctx)
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        local link
        if item.is_image then
          link = string.format("![%s](%s)", item.name, item.name)
        else
          link = string.format("[[%s]]", item.name)
        end
        vim.api.nvim_put({ link }, "c", true, true)
      end
    end,
  })
end

return {
  "folke/snacks.nvim",
  -- nb は bash スクリプトで初回起動が遅い。起動後にバックグラウンドで 1 回叩いて
  -- ウォームアップし、最初の <leader>np / <leader>ng の待ちを減らす。
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        vim.fn.jobstart({ "nb", "list", "--no-color" }, { detach = true })
      end,
    })
  end,
  keys = {
    -- <leader>n 単体 (Notification History) を無効化して nb グループ用に解放
    -- 通知履歴は <leader>un / :Noice で参照可
    { "<leader>n", false },
    { "<leader>na", add_note, desc = "nb add" },
    { "<leader>ni", import_image, desc = "nb import image" },
    { "<leader>nl", link_item, desc = "nb link" },
    { "<leader>np", pick_notes, desc = "nb picker" },
    { "<leader>ng", grep_notes, desc = "nb grep" },
  },
}
