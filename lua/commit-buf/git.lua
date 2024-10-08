local utils = require("commit-buf.utils")
local M = {}

local cmds= {
  git_status = {
    "git",
    "status"
  },
}

local err_msgs = {
  git_status = "cannot achieve git status",
}

---available keys
---  git_status
---@param key string
---@return table
function M.get_output_table(key)
  local cmd = cmds[key]
  local result_table, _= utils.get_result_table(cmd, 0, 0, 100)
  if result_table == nil then
    result_table = { err_msgs[key] }
  end
  return result_table
end

return M
