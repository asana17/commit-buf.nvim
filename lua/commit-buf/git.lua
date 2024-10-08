local utils = require("commit-buf.utils")

local M = {}

---@type table<git_key, table>
local commands= {
  git_log = {
    "git",
    "log",
    "--decorate",
    "-5",
  },
}

---@type table<git_key, string>
local err_msgs = {
  git_log = "cannot achieve git log",
}

---get output of git command specified by key
---@param key git_key
---@return table<string>
function M.get_output_table(key)
  local cmd = commands[key]
  local result_table, _= utils.run_system_cmd(cmd, 0, 0, 100)
  if result_table == nil then
    result_table = { err_msgs[key] }
  end
  return result_table
end

return M
