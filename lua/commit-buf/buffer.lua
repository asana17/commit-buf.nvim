local log = require("commit-buf.log")

local M = {}

---@alias buf_handle integer
---@type buf_handle|nil could be nil, but should not be zero
local g_handle

---@alias vim_buf_opt string
---@type table<vim_buf_opt, any>
local local_opts_default = {
  bufhidden = "wipe",
  buftype = "nofile",
  readonly = true,
  buflisted = false,
  swapfile = false,
  modifiable = false,
}

---create customized buffer
---@return nil
function M.create()
  local handle = vim.api.nvim_create_buf(false, true)
  if handle == 0 then
    log.debug("create(): nvim_create_buf() failed")
    g_handle = nil
  end

  g_handle = handle

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {buf = handle})
  end
end

---@return buf_handle|nil #can be nil, but should not be zero
function M.get_handle()
  return g_handle
end

return M
