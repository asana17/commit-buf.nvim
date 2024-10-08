local utils = require("commit-buf.utils")
local M = {}

local local_opts = {
  git_status = {
    filetype = "gitrebase",
  }
}

local local_opts_default = {
  bufhidden = "wipe",
  buftype = "nofile",
  readonly = true,
  buflisted = false,
  swapfile = false,
  modifiable = false,
  modified = false,
}

---generate a temporal buffer name from key
---@param key string
---@return string
local function generate_temp_name(key)
  local temp_buf_name = "__"..utils.plugin_name .. "__" .. key .. "__"
  return temp_buf_name
end

---available keys
---  git_status
---@param key string
---@param output_table table
---@return nil
function M.init(key, output_table)
  vim.cmd("enew")
  local cur_buf = vim.api.nvim_get_current_buf()

  local buf_name = generate_temp_name(key)
  vim.api.nvim_buf_set_name(cur_buf, buf_name)

  vim.api.nvim_buf_set_lines(cur_buf, 0, -1, false, output_table)

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {buf = cur_buf})
  end
  for k, v in pairs(local_opts[key]) do
    vim.api.nvim_set_option_value(k, v, {buf = cur_buf})
  end
end

return M
