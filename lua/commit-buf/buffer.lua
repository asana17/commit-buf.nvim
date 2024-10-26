local log = require("commit-buf.log")

local M = {}

---@type table<git_key, string>
local buf_names = {
  git_log = "git log of previous 5 commits",
  git_diff_staged = "staged change",
  git_show_head = "HEAD",
  git_staged_file_list = "press Enter to show file diff under cursor",
}

---@alias buf_handle integer
---@type table<git_key, buf_handle|nil>
---these handles could be nil, but should not be zero
local handles = {}

---@type table<git_key, table>
local local_opts = {
  git_diff_staged = {
    filetype = "git",
  },
  git_log= {
    filetype = "gitrebase",
  },
  git_show_head = {
    filetype = "git",
  },
  git_staged_file_list = {
    filetype = "git",
  },
}

---@alias vim_buf_opt string
---@type table<vim_buf_opt, any>
local local_opts_default = {
  bufhidden = "wipe",
  buftype = "nofile",
  readonly = true,
  buflisted = false,
  swapfile = false,
  modifiable = false,
}

---@type table<vim_buf_opt, any>
local local_opts_make_mutable = {
  readonly = false,
  modifiable = true,
}

---@type table<vim_buf_opt, any>
local local_opts_make_immutable = {
  readonly = true,
  modifiable = false,
}

---@param key git_key
---@return string
local function generate_temp_name(key)
  local temp_buf_name = log.get_message_prefix() .. " " .. key
  return temp_buf_name
end

---create customized buffer by key
---@param key git_key
---@return nil
function M.create(key)
  local handle = vim.api.nvim_create_buf(false, true)
  if handle == 0 then
    log.debug("create(): nvim_create_buf() failed for " .. key)
    handles[key] = nil
    return
  end
  handles[key] = handle

  local buf_name = buf_names[key]
  if not buf_name then
    buf_name = generate_temp_name(key)
  end
  vim.api.nvim_buf_set_name(handle, buf_name)


  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {buf = handle})
  end

  for k, v in pairs(local_opts[key]) do
    vim.api.nvim_set_option_value(k, v, {buf = handle})
  end
end

---get content by key and set it to buffer
---@param key git_key
---@param content table
---@return nil
function M.set_content(key, content)
  if not handles[key] then
    log.debug("set_content() failed for ".. key)
    return
  end

  for k, v in pairs(local_opts_make_mutable) do
    vim.api.nvim_set_option_value(k, v, {buf = handles[key]})
  end

  vim.api.nvim_buf_set_lines(handles[key], 0, -1, false, content)

  for k, v in pairs(local_opts_make_immutable) do
    vim.api.nvim_set_option_value(k, v, {buf = handles[key]})
  end
end

---set keymaps to buffer specified by key
---@param key git_key
---@param keymaps table<integer, any>
function M.set_keymaps(key, keymaps)
  if not keymaps then
    return
  end

  if not handles[key] then
    log.debug("set_keymaps() failed for " .. key)
  end

  for _, keymap in ipairs(keymaps) do
    vim.api.nvim_buf_set_keymap(handles[key], keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
  end
end

---get buffer handle by key
---@param key git_key
---@return buf_handle|nil #could be nil, but should not be zero
function M.get_handle(key)
  return handles[key]
end

return M
