local window = require("commit-buf.window")

local M = {}

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
      callback = window.open,
    }
  )
end

---@return nil
function M.setup()
  set_autocmd()
end

return M
