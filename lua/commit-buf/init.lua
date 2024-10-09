local buffer = require("commit-buf.buffer")
local git = require("commit-buf.git")
local option = require("commit-buf.option")
local window = require("commit-buf.window")

local M = {}

---@alias git_key "git_diff_staged"|"git_log"
---@type git_key[]
local git_keys = {
  [1] = "git_diff_staged",
  [2] = "git_log",
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

  vim.api.nvim_win_set_buf(win_handle, buf_handle)
end

---@return nil
local function setup()
  for _, key in ipairs(git_keys) do
    setup_git(key)
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
