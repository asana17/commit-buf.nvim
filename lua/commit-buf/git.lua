local buffer= require("commit-buf.buffer")
local utils = require("commit-buf.utils")
local M = {}

local cmds= {
  git_status = {
    "git",
    "status"
  },
}

local setlocal_opts = {
  git_status = buffer.setlocal_opt_fixed_readonly .. " " .. "filetype=gitrebase",
}

local window_cmds = {
  git_status = "belowright split",
}

local fallback_msgs = {
  git_status = "",
}

---@param key string
---@return nil
local function init(key)
  local cmd = cmds[key]
  local setlocal_opt = setlocal_opts[key]
  local table, _= utils.get_result_table(cmd, 0, 0, 100)
  if table == nil then
    table = { fallback_msgs[key] }
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, table)
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
end

return M
