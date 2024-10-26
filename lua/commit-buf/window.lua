local log = require("commit-buf.log")

local M = {}

---@type table<git_key, git_key|"commit_buf">
local base_window = {
  git_diff_staged = "git_show_head",
  git_log= "commit_buf",
  git_show_head = "commit_buf",
  git_staged_file_list = "commit_buf",
}

---@type table<git_key, table>
local configs = {
  git_diff_staged = {
    split = "below",
  },
  git_show_head = {
    split = "right",
  },
  git_log = {
    split = "below",
  },
  git_staged_file_list = {
    split = "below",
  },
}

---@alias win_handle integer
---@type table<git_key|"commit_buf", win_handle|nil>
---these handles could be nil, but should not be zero
local handles = {}

---@type boolean
local initialized = false

---@type table<git_key, table>
local local_opts = {
  git_diff_staged = {},
  git_log = {
    number = false,
  },
  git_show_head = {},
  git_staged_file_list = {},
}

---@alias vim_win_opt string
---@type table<vim_win_opt, any>
local local_opts_default = {
  list = false,
  foldenable = false,
}

---@param key git_key
---@return nil
local function update_config(key)
  configs[key]["win"] = handles[base_window[key]]
end

---run vim cmd on window specified by key
---@param key git_key
---@param cmd_str string
---@return nil
function M.run_vim_cmd(key, cmd_str)
  if not handles[key] then
    log.debug("run_vim_cmd(): window is not opened for " .. key)
    return
  end

  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(handles[key])
  vim.cmd(cmd_str)
  vim.api.nvim_set_current_win(cur_win)
end

---open customized window by key
---@param key git_key
---@return nil
function M.open(key)
  if not initialized then
    initialized = true
    handles["commit_buf"] = vim.api.nvim_get_current_win()
  end

  update_config(key)

  local handle = vim.api.nvim_open_win(0, true, configs[key])
  if handle == 0 then
    log.debug("open(): nvim_open_win() failed for " .. key)
    handles[key] = nil
    return
  end

  handles[key] = handle

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {win = handle})
  end

  for k, v in pairs(local_opts[key]) do
    vim.api.nvim_set_option_value(k, v, {win = handle})
  end
end

---get window handle by key
---@param key git_key
---@return win_handle|nil #can be nil, but should not be zero
function M.get_handle(key)
  return handles[key]
end

---close window by key
---if window is not existing, just return
---@return nil
function M.close(key)
  if not handles[key] then
    return
  end
  vim.api.nvim_win_close(handles[key], true)
  handles[key] = nil
end

return M
