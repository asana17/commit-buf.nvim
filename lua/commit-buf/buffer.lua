local utils = require("commit-buf.utils")
local M = {}

M.setlocal_opt_fixed_readonly = "nonumber bufhidden=wipe buftype=nofile " ..
  "readonly nolist nobuflisted noswapfile nomodifiable nomodified nofoldenable"

---generate a temporal buffer name from key
---@param key string
---@return string
function M.generate_temp_name(key)
  local temp_buf_name = "__"..utils.plugin_name .. "__" .. key .. "__"
  return temp_buf_name
end

return M
