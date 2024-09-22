local function telescope_vim_keybindings()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local mode_labels = {
    n = 'Normal', i = 'Insert', v = 'Visual', x = 'Visual Block',
    s = 'Select', o = 'Operator-pending', c = 'Command-line', t = 'Terminal',
  }

  local keybindings = {}
  local max_len_lhs = 0
  local max_len_mode = 0

  local common_vim_keybindings = require('common_keybindings')

  local additional_keybindings = {
    { mode = "Normal", lhs = "<C-q>", desc = "In Telescope: Add selections to quickfix list" },
    { mode = "Ex", lhs = ":%s/old_word/new_word/cg", desc = "Search and replace with confirmation in current buffer" },
    { mode = "Ex", lhs = ":cdo s/old_word/new_word/cg", desc = "Execute command on each entry in quickfix list" },
    { mode = "Ex", lhs = ":cfdo s/old_word/new_word/cg", desc = "Execute command on each file in quickfix list" },
  }

  local all_keybindings = vim.tbl_deep_extend("force", {}, common_vim_keybindings, additional_keybindings)

  for _, binding in ipairs(all_keybindings) do
    table.insert(keybindings, binding)
    max_len_lhs = math.max(max_len_lhs, #binding.lhs)
    max_len_mode = math.max(max_len_mode, #binding.mode)
  end

  local function extract_keymaps(mode, keymaps)
    for _, keymap in ipairs(keymaps) do
      if not string.find(keymap.lhs, '<Plug>') then
        table.insert(keybindings, {
          mode = mode_labels[mode] or mode,
          lhs = keymap.lhs,
          rhs = keymap.rhs or (keymap.callback and 'Lua function') or '',
          desc = keymap.desc or '',
        })
        max_len_lhs = math.max(max_len_lhs, #keymap.lhs)
        max_len_mode = math.max(max_len_mode, #(mode_labels[mode] or mode))
      end
    end
  end

  for mode, _ in pairs(mode_labels) do
    extract_keymaps(mode, vim.api.nvim_get_keymap(mode))
    extract_keymaps(mode, vim.api.nvim_buf_get_keymap(0, mode))
  end

  local function make_display(entry)
    local mode = string.format("%-" .. max_len_mode .. "s", entry.mode)
    local lhs = string.format("%-" .. (max_len_lhs + 15) .. "s", entry.lhs:gsub('%s', '<Space>'))
    local desc = string.format("%-65s", entry.desc:sub(1, 65))
    local rhs = (entry.rhs or ''):gsub('\n', '\\n'):sub(1, 40)
    return string.format("%s │ %s │ %s │ %s", mode, lhs, desc, rhs)
  end

  pickers.new({}, {
    prompt_title = 'Vim Keybindings',
    finder = finders.new_table {
      results = keybindings,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display(entry),
          ordinal = entry.mode .. ' ' .. entry.lhs .. ' ' .. entry.desc .. ' ' .. (entry.rhs or ''),
        }
      end,
    },
    sorter = conf.generic_sorter{},
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_put({make_display(selection.value)}, '', false, true)
      end)
      return true
    end,
  }):find()
end


local wk = require("which-key")
wk.add({
  {"<leader>sK", telescope_vim_keybindings, desc = 'Search All Keybindings'}
})

vim.keymap.set('n', '<leader>sK', telescope_vim_keybindings, { desc = '[S]earch All [K]eybindings' })
