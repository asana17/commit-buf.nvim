local buffer = require("commit-buf.buffer")
local git = require("commit-buf.git")
local window = require("commit-buf.window")

local M = {}

local git_keys = {
  [1] = "git_status",
}

---@param key string
---@return nil
local function setup_git(key)
  local output_table = git.get_output_table(key)
  window.open(key)
  buffer.init(key, output_table)
end

---@return nil
local function setup()
  for _, key in ipairs(git_keys) do
    setup_git(key)
  end
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
