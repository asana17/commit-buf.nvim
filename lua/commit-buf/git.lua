local utils = require("commit-buf.utils")

local M = {}

---@type table<git_key, table>
local commands= {
  git_diff_staged = {
    "git",
    "diff",
    "--no-color",
    "--cached",
  },
  git_log = {
    "git",
    "log",
    "--decorate",
    "-5",
  },
  git_staged_file_list = {
    "git",
    "diff",
    "--no-color",
    "--name-only",
    "--cached",
  },
}

---@type table<git_key, string>
local err_msgs = {
  git_diff_staged = "cannot achieve staged git diff",
  git_log = "cannot achieve git log",
  git_staged_file_list = "cannot achieve staged file path",
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

---@return string
local function get_root_dir()
  local table, _ = utils.run_system_cmd({"git", "rev-parse", "--show-toplevel"}, 0, 0, 100)
  if table == nil then
    return ""
  end
  return table[1]
end

---@param path string
---@return table<string>
function M.diff_relative_path(path)
  local cmd_table = commands["git_diff_staged"]
  table.insert(cmd_table, get_root_dir() .. "/" .. path)
  local result_table, _ = utils.run_system_cmd(cmd_table, 0, 0, 100)
  table.remove(cmd_table)
  if result_table == nil then
    result_table = { err_msgs["git_diff_staged"] }
  end
  return result_table
end

return M
