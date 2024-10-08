local buffer = require("commit-buf.buffer")
local window = require("commit-buf.window")
local M = {}

local function setup()
  window.open()
  buffer.init()
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
