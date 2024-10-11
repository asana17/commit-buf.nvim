local buffer= require("commit-buf.buffer")
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

local setlocal_opts = {
  git_diff = buffer.setlocal_opt_fixed_readonly .. " " .. "filetype=git",
  git_diff_name_only = buffer.setlocal_opt_fixed_readonly .. " " .. "filetype=git",
  git_status = buffer.setlocal_opt_fixed_readonly .. " " .. "filetype=gitrebase",
}

local window_cmds = {
  git_diff = "belowright vsplit",
  git_diff_name_only = "belowright split",
  git_status = "belowright split",
}

local err_msgs = {
  git_status = "cannot achieve git status",
  git_diff_name_only = "cannot achieve diff file path",
  git_diff= "cannot achieve git diff",
}

local keymaps = {
  git_diff_name_only = {
    mode = "n",
    lhs = "<CR>",
    rhs = ":lua require('commit-buf.git').file_diff_under_cursor()<CR>",
    opt = { silent = true },
  },
}

local win_nums = {}

---@param key string
---@return nil
local function init(key)
  win_nums[key] = vim.api.nvim_get_current_win()
  local cmd = cmds[key]
  local setlocal_opt = setlocal_opts[key]
  local table, _= utils.get_result_table(cmd, 0, 0, 100)
  if table == nil then
    table = { err_msgs[key] }
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, table)
  vim.cmd.setlocal(setlocal_opt)
  local keymap = keymaps[key]
  if keymap == nil then
    return
  end
  vim.api.nvim_buf_set_keymap(0, keymap.mode, keymap.lhs, keymap.rhs, keymap.opt)
end

---@param key string
---@return nil
local function open_window(key)
  local window_cmd = window_cmds[key]
  local buf_name = buffer.generate_temp_name(key)
  vim.cmd(window_cmd .. " " .. buf_name)
  init(key)
end

---@return string
local function get_root_dir()
  local table, _ = utils.get_result_table({"git", "rev-parse", "--show-toplevel"}, 0, 0, 100)
  if table == nil then
    return ""
  end
  return table[1]
end

---@return nil
function M.file_diff_under_cursor()
  local current_line = vim.api.nvim_get_current_line()
  vim.cmd("wincmd l")
  table.insert(cmds.git_diff, get_root_dir() .."/" .. current_line)
  local stdout_table, _ = utils.get_result_table(cmds.git_diff, 0, 0, 100)
  table.remove(cmds.git_diff)
  if stdout_table == nil then
    stdout_table = { err_msgs.git_diff }
  end
  vim.cmd.setlocal("noreadonly modifiable")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, stdout_table)
  vim.cmd.setlocal("readonly nomodifiable")
  vim.cmd("0")
  vim.api.nvim_set_current_win(win_nums["git_diff_name_only"])
end

---@return nil
function M.open_windows()
  open_window("git_diff")
  vim.cmd("wincmd p")
  open_window("git_status")
  open_window("git_diff_name_only")
end

return M
