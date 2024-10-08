local buffer = require("commit-buf.buffer")
local window = require("commit-buf.window")

local M = {}

---@return nil
local function setup()
  window.open()
  local win_handle = window.get_handle()
  if not win_handle then
    return
  end

  buffer.create()
  local buf_handle = buffer.get_handle()
  if not buf_handle then
    window.close()
    return
  end

  vim.api.nvim_win_set_buf(win_handle, buf_handle)
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

---@return nil
function M.setup()
  set_autocmd()
end

return M
