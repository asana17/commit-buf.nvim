local utils = require("commit-buf.utils")
local M = {}

local buf_names = {
  git_diff_name_only = "press Enter to show file diff under cursor"
}

local local_opts = {
  git_diff = {
    filetype = "git",
  },
  git_diff_name_only = {
    filetype = "git",
  },
  git_status = {
    filetype = "gitrebase",
  }
}

local local_opts_default = {
  bufhidden = "wipe",
  buftype = "nofile",
  readonly = true,
  buflisted = false,
  swapfile = false,
  modifiable = false,
  modified = false,
}

local local_opts_make_mutable = {
  readonly = false,
  modifiable = true,
}

local local_opts_make_immutable = {
  readonly = true,
  modifiable = false,
}

local nums = {}

---generate a temporal buffer name from key
---@param key string
---@return string
local function generate_temp_name(key)
  local temp_buf_name = "__"..utils.plugin_name .. "__" .. key .. "__"
  return temp_buf_name
end

---available keys
---  git_diff
---  git_diff_name_only
---  git_status
---@param key string
---@param output_table table
---@param keymap table
---@return nil
function M.init(key, output_table, keymap)
  vim.cmd("enew")
  local cur_buf = vim.api.nvim_get_current_buf()
  nums[key] = cur_buf

  local buf_name = buf_names[key]
  if buf_name == nil then
    buf_name = generate_temp_name(key)
  end
  vim.api.nvim_buf_set_name(cur_buf, buf_name)

  vim.api.nvim_buf_set_lines(cur_buf, 0, -1, false, output_table)

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {buf = cur_buf})
  end
  for k, v in pairs(local_opts[key]) do
    vim.api.nvim_set_option_value(k, v, {buf = cur_buf})
  end

  if keymap == nil then
    return
  end
  vim.api.nvim_buf_set_keymap(cur_buf, keymap.mode, keymap.lhs, keymap.rhs, keymap.opt)
end

---@param key string
---@param output_table table
---@return nil
function M.set(key, output_table)
  for k, v in pairs(local_opts_make_mutable) do
    vim.api.nvim_set_option_value(k, v, {buf = nums[key]})
  end
  vim.api.nvim_buf_set_lines(nums[key], 0, -1, false, output_table)
  for k, v in pairs(local_opts_make_immutable) do
    vim.api.nvim_set_option_value(k, v, {buf = nums[key]})
  end
end

return M
