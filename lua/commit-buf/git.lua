local buffer= require("commit-buf.buffer")
local utils = require("commit-buf.utils")
local M = {}

local cmds= {
  git_status = "git status",
  git_diff= "git diff --no-color --cached",
}

local setlocal_opts = {
  git_status = buffer.setlocal_opt_fixed_readonly .. " " .. "filetype=gitrebase",
  git_diff = buffer.setlocal_opt_fixed_readonly .. " " .. "filetype=git",
}

local window_cmds = {
  git_status = "belowright split",
  git_diff = "botright vsplit",
}

---@param key string
---@return nil
local function init(key)
  local cmd = cmds[key]
  local setlocal_opt = setlocal_opts[key]
  local table = utils.get_result_table(cmd)
  buffer.set_table(table)
  vim.cmd.setlocal(setlocal_opt)
end

---@param key string
---@return nil
local function open_window(key)
  local window_cmd = window_cmds[key]
  local buf_name = buffer.generate_temp_name(key)
  vim.cmd(window_cmd .. " " .. buf_name)
  init(key)
end

---@return nil
function M.open_windows()
  open_window("git_status")
  open_window("git_diff")
end

return M
