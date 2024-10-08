local M = {}

---@type table<string, any>
local configs_default = {
    split = "right",
}

---@alias win_handle integer
---@type win_handle|nil could be nil, but should not be zero
local g_handle

---@type win_handle|nil could be nil, but should not be zero
local handle_base

---@type boolean
local initialized = false

---@alias vim_win_opt string
---@type table<vim_win_opt, any>
local local_opts_default = {
  list = false,
  foldenable = false,
}

---@return nil
local function update_config()
  configs_default["win"] = handle_base
end

---open window using config
---@return nil
function M.open()
  if not initialized then
    initialized = true
    handle_base = vim.api.nvim_get_current_win()
  end

  update_config()

  local handle = vim.api.nvim_open_win(0, true, configs_default)
  if handle == 0 then
    g_handle = nil
  end

  g_handle = handle

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {win = handle})
  end
end

---@return win_handle|nil #can be nil, but should not be zero
function M.get_handle()
  return g_handle
end

---close window. if window is not opened, just return
---@return nil
function M.close()
  if not g_handle then
    return
  end
  vim.api.nvim_win_close(g_handle, true)
  g_handle = nil
end

return M
