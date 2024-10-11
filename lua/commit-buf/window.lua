local M = {}

local base_window = {
  git_diff = "commit_buf",
  git_diff_name_only = "git_status",
  git_status = "commit_buf",
}

local configs = {
  git_diff = {
    split = "below",
  },
  git_diff_name_only = {
    split = "below",
  },
  git_status = {
    split = "right",
  }
}

local initialized = false

local local_opts = {
  git_diff = {},
  git_diff_name_only = {},
  git_status = {
    number = false,
  }
}

local local_opts_default = {
  list = false,
  foldenable = false,
}

local nums = {}

---@param key string
---@return nil
local function update_config(key)
  configs[key]["win"] = nums[base_window[key]]
end

---available keys
---  git_diff
---  git_diff_name_only
---  git_status
---@param key string
---@return nil
function M.open(key)
  if not initialized then
    initialized = true
    nums["commit_buf"] = vim.api.nvim_get_current_win()
  end

  update_config(key)
  vim.api.nvim_open_win(0, true, configs[key])

  local cur_win = vim.api.nvim_get_current_win()
  nums[key] = cur_win

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {win = cur_win})
  end
  for k, v in pairs(local_opts[key]) do
    vim.api.nvim_set_option_value(k, v, {win = cur_win})
  end
end

return M
