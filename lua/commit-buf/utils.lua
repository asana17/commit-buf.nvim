local uv = vim.loop
local M = {}
M.plugin_name = "commit-buf"

---prefix with current directory path
---@param str string
---@return string
function M.prefix_path(str)
  return uv.cwd() .. "/" .. str
end

---run command synchronously and output result string table
---pass expected exit_code and signal
---set timeout by second
---@param cmd table
---@param exit_code integer
---@param signal integer
---@param timeout integer
---@return table | nil, table | nil
function M.get_result_table(cmd, exit_code, signal, timeout)
  local obj = vim.system(cmd, { text = true, timeout = timeout }):wait()
  if obj.code ~= exit_code then
    if signal ~= obj.signal then
      return nil, nil
    end
  end
  local stdout_table = vim.split(obj.stdout, '\n')
  local stderr_table = vim.split(obj.stderr, '\n')
  return stdout_table, stderr_table
end

return M
