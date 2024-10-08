local uv = vim.loop
local M = {}

---prefix with current directory path
---@param str string
---@return string
function M.prefix_path(str)
  return uv.cwd() .. "/" .. str
end

return M
