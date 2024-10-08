local M = {}

local local_opts_default = {
  bufhidden = "wipe",
  buftype = "nofile",
  readonly = true,
  buflisted = false,
  swapfile = false,
  modifiable = false,
  modified = false,
}

---@return nil
function M.init()
  vim.cmd("enew")
  local cur_buf = vim.api.nvim_get_current_buf()
  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {buf = cur_buf})
  end
end

return M
