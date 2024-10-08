local M = {}

local window_cmds = {
  default = "botright vsplit",
}

---use window key to open customized window
---
---available key:
---  default
---@param key string
---@return nil
function M.open(key)
  local window_cmd = window_cmds[key]
  vim.cmd(window_cmd.. " " .. key)
end

---@return nil
function M.setup()
  M.open("default")
end

return M
