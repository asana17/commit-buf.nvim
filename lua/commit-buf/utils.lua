local M = {}

---@param result_table table<string>|nil
---@return nil
local function remove_whiteline(result_table)
  while result_table and result_table[#result_table] == "" do
    table.remove(result_table)
  end
end

---run command synchronously and output result string table
---pass expected exit_code and signal
---set timeout by second
---@param cmd table<string>
---@param exit_code integer
---@param signal integer
---@param timeout integer
---@return table<string> | nil, table<string> | nil
function M.run_system_cmd(cmd, exit_code, signal, timeout)
  if not cmd or not exit_code or not signal or not timeout then
    return nil, nil
  end

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

---return true if result_table is empty
---@param result_table table
---@return boolean
function M.is_result_table_empty(result_table)
  if result_table == nil then
    return true
  end
  local empty = true
  for i = 1, #result_table do
    if result_table[i] ~= "" then
      empty = false
      goto end_of_loop end
  end
  ::end_of_loop::
  return empty
end

return M
