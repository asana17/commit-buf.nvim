local buffer = require("commit-buf.buffer")
local git = require("commit-buf.git")
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
  vim.cmd.setlocal(buffer.setlocal_opt_fixed_readonly)
end

---@return nil
function M.setup()
  git.open_windows()
end

return M
