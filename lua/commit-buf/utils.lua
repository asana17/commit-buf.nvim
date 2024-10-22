local M = {}

---@param result_table table
---@return nil
local function remove_whiteline(result_table)
  while result_table ~= nil and result_table[#result_table] == "" do
    table.remove(result_table)
  end
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
  remove_whiteline(stdout_table)
  remove_whiteline(stderr_table)
  return stdout_table, stderr_table
end

return M
