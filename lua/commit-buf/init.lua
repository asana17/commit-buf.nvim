local buffer = require("commit-buf.buffer")
local git = require("commit-buf.git")
local window = require("commit-buf.window")

local M = {}

local git_keys = {
  [1] = "git_diff",
  [2] = "git_status",
  [3] = "git_diff_name_only",
}

local keymaps = {
  git_diff_name_only = {
    mode = "n",
    lhs = "<CR>",
    rhs = ":lua require('commit-buf').file_diff_under_cursor()<CR>",
    opt = { silent = true },
  },
}

---@param key string
---@return nil
local function setup_git(key)
  local output_table = git.get_output_table(key)
  window.open(key)
  buffer.init(key, output_table, keymaps[key])
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
  buffer.set("git_diff", file_diff)
end


---@return nil
function M.set_autocmd()
  M.augroup = vim.api.nvim_create_augroup(
    "commit_buf_nvim",
    {})

  vim.api.nvim_create_autocmd(
    {"BufRead", "BufNewFile"},
    {
      group = M.augroup,
      pattern = '*.comtxt',
      callback = setup,
    })
end

---@return nil
function M.setup()
  M.set_autocmd()
end

return M
