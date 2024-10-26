local buffer = require("commit-buf.buffer")
local git = require("commit-buf.git")
local option = require("commit-buf.option")
local window = require("commit-buf.window")

local M = {}

---@alias git_key "git_diff_staged"|"git_log"|"git_show_head"|"git_staged_file_list"
---@type git_key[]
local git_keys = {
  [1] = "git_show_head",
  [2] = "git_diff_staged",
  [3] = "git_log",
  [4] = "git_staged_file_list",
}

---@type table<git_key, table>
local keymaps = {
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
local function setup_git(key)
  window.open(key)
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
  buffer.set_keymaps(key, keymaps[key])

  vim.api.nvim_win_set_buf(win_handle, buf_handle)
end

---@return nil
local function setup()
  for _, key in ipairs(git_keys) do
    setup_git(key)
  end
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
