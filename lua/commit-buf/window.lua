local M = {}

local base_window = "commit_buf"

local configs_default = {
    split = "right",
}

local initialized = false

local local_opts_default = {
  list = false,
  foldenable = false,
}

local nums = {}

---@return nil
local function update_config()
  configs_default["win"] = nums[base_window]
end

---use window key to open customized window
---@return nil
function M.open()
  if not initialized then
    initialized = true
    nums["commit_buf"] = vim.api.nvim_get_current_win()
  end
  update_config()
  vim.api.nvim_open_win(0, true, configs_default)
  local cur_win = vim.api.nvim_get_current_win()
  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {win = cur_win})
  end
end

return M
