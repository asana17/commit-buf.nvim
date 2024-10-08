local uv = vim.loop
local M = {}
M.plugin_name = "commit-buf"

---prefix with current directory path
---@param str string
---@return string
function M.prefix_path(str)
  return uv.cwd() .. "/" .. str
end

---convert string to table
---@param str string
---@return table
function M.str_to_table(str)
  return vim.split(str, '\n')
end

---run command and output result string table
function M.get_result_table(cmd_str)
  local result_str = vim.fn.system(cmd_str)
  local result_table = M.str_to_table(result_str)
  return result_table
end

return M
