local buffer = require("commit-buf.buffer")
local git = require("commit-buf.git")
local option = require("commit-buf.option")
local window = require("commit-buf.window")

local M = {}

---@alias git_key "git_diff_staged"|"git_log"|"git_show_head"|"git_staged_file_list"
---@alias float_key "help"
---@type git_key[]
local git_keys = {
  [1] = "git_diff_staged",
  [2] = "git_log",
  [3] = "git_show_head",
  [4] = "git_staged_file_list",
}

---@type table<git_key|float_key|"commit_buf", table<integer, table<string, any>>>
local global_keymaps = {
  commit_buf = {
    [1] = {
      mode = "n",
      lhs = "<ESC><ESC>",
      rhs = ":lua require('commit-buf').move_to_win('commit_buf')<CR>",
      opts = { silent = true },
    },
  },
  help = {
    [1] = {
      mode = "n",
      lhs = "?",
      rhs = ":lua require('commit-buf').help()<CR>",
      opts = { silent = true },
    },
  },
}

---@type table<float_key, table<integer, table<string, any>>>
local global_keymaps_float = {
  help = {
    [1] = {
      mode = "n",
      lhs = "?",
      rhs = ":lua require('commit-buf').close_help()<CR>",
      opts = { silent = true },
    },
  },
}

---@type table<string>
local help_content = {
  " ?           :   show/close this help",
  " <ESC><ESC>  :   move to commit buf window",
}

---@type table<git_key|float_key, table<integer, table<string, any>>>
local local_keymaps = {
  git_staged_file_list = {
    [1] = {
      mode = "n",
      lhs = "<CR>",
      rhs = ":lua require('commit-buf').file_diff_under_cursor()<CR>",
      opts = { silent = true },
    },
  },
}

---@param key git_key
---@return nil
local function git_set_buf_to_win(key)
  local win_handle = window.get_handle(key)
  if not win_handle then
    return
  end

  buffer.create(key)
  local buf_handle = buffer.get_handle(key)
  if not buf_handle then
    window.close(key)
    return
  end

  local output_table = git.get_output_table(key)
  buffer.set_content(key, output_table)
  buffer.set_keymaps(key,local_keymaps[key])

  vim.api.nvim_win_set_buf(win_handle, buf_handle)
end

---@return nil
local function set_global_keymaps()
  for _, keymaps in pairs(global_keymaps) do
    for _, keymap in ipairs(keymaps) do
      vim.api.nvim_set_keymap(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
    end
  end
end

---@return nil
local function setup()
  window.open()
  for _, key in ipairs(git_keys) do
    git_set_buf_to_win(key)
  end
  window.close_if_dependent_win_not_opened()
  set_global_keymaps()
end

---@return nil
function M.file_diff_under_cursor()
  local current_line = vim.api.nvim_get_current_line()
  local file_diff = git.diff_relative_path(current_line)
  buffer.set_content("git_diff_staged", file_diff)
  local file_head = git.show_head_relative_path(current_line)
  buffer.set_content("git_show_head", file_head)
  local file_staged = git.show_staged_relative_path(current_line)
  buffer.set_content("git_diff_staged", file_staged)
  window.run_vim_cmd("git_show_head", "diffthis")
  window.run_vim_cmd("git_diff_staged", "diffthis")
end

---@return nil
function M.move_to_win(key)
  local win_handle = window.get_handle(key)
  if not win_handle then
    return
  end
  vim.api.nvim_set_current_win(win_handle)
end

---@return nil
function M.help()
  window.open_float("help")
  local win_handle = window.get_handle("help")
  if not win_handle then
    return
  end

  buffer.create("help")
  local buf_handle = buffer.get_handle("help")
  if not buf_handle then
    window.close("help")
    return
  end

  buffer.set_content("help", help_content)

  vim.api.nvim_win_set_buf(win_handle, buf_handle)
  for _, keymap in ipairs(global_keymaps["help"]) do
    vim.api.nvim_del_keymap(keymap.mode, keymap.lhs)
  end
  for _, keymap in ipairs(global_keymaps_float["help"]) do
    vim.api.nvim_set_keymap(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
  end
end

function M.close_help()
  window.close("help")
  for _, keymap in ipairs(global_keymaps_float["help"]) do
    vim.api.nvim_del_keymap(keymap.mode, keymap.lhs)
  end
  for _, keymap in ipairs(global_keymaps["help"]) do
    vim.api.nvim_set_keymap(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
  end
end

---@return nil
local function set_autocmd()
  M.augroup = vim.api.nvim_create_augroup(
    "commit_buf_nvim",
    {}
  )

  vim.api.nvim_create_autocmd(
    {"BufRead", "BufNewFile"},
    {
      group = M.augroup,
      pattern = '*.comtxt',
      callback = setup,
    }
  )
end

---@param config CommitBufOptions | nil
---@return nil
function M.setup(config)
  option.setup(config)
  set_autocmd()
end

return M
