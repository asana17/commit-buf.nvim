local M = {}

local base_window = "commit_buf"

local configs_default = {
    split = "right",
}

local initialized = false

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
end

return M
