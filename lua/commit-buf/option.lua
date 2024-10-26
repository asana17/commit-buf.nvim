local M = {}

---@class CommitBufOptions
local defaults = {
  ---@class CommitBufWindowOptions
  window = {
    ---@type table<integer, (git_key|"commit_buf")[]>
    columns = {
      [1] = {
        "commit_buf",
        "git_staged_file_list",
        "git_log",
      },
      [2] = {
        "git_show_head",
        "git_diff_staged",
      },
    },
  },
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
