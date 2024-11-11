local M = {}

---@class CommitBufOptions
local defaults = {
  verbose = false,
}

---@type CommitBufOptions
M.options = {}

---setup option using user config
---@param config CommitBufOptions| nil
---@return nil
function M.setup(config)
  M.options = vim.tbl_deep_extend("force", defaults, config or {})
end

return M
