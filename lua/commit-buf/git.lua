local utils = require("commit-buf.utils")
local M = {}

local cmds= {
  git_diff = {
    "git",
    "diff",
    "--no-color",
    "--cached",
  },
  git_diff_name_only = {
    "git",
    "diff",
    "--no-color",
    "--name-only",
    "--cached",
  },
  git_status = {
    "git",
    "status",
  }
}

local err_msgs = {
  git_diff= "cannot achieve git diff",
  git_diff_name_only = "cannot achieve diff file path",
  git_status = "cannot achieve git status",
}

---available keys
---  git_diff
---  git_diff_name_only
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

---@return string
local function get_root_dir()
  local table, _ = utils.get_result_table({"git", "rev-parse", "--show-toplevel"}, 0, 0, 100)
  if table == nil then
    return ""
  end
  return table[1]
end

---@param path string
---@return table
function M.diff_relative_path(path)
  table.insert(cmds.git_diff, get_root_dir() .."/" .. path)
  local result_table, _ = utils.get_result_table(cmds.git_diff, 0, 0, 100)
  table.remove(cmds.git_diff)
  if result_table == nil then
    result_table = { err_msgs.git_diff }
  end
  return result_table
end

return M
