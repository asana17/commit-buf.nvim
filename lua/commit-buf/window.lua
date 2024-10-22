local M = {}

---@type table<string, any>
local configs_default = {
    split = "right",
}

---@alias win_handle integer
---@type win_handle|nil could be nil, but should not be zero
local handle_base

---@type boolean
local initialized = false

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

  vim.api.nvim_open_win(0, true, configs_default)
end

return M
