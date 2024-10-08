local option = require("commit-buf.option")
local M = {}

---@type string
local plugin_name =
  debug.getinfo(1, "S").source:match("([^/\\]+)/[^/\\]+$") or ""

---@type string
local default_print_prefix = "[" .. plugin_name ..  "] "

---@param msg string
---@param hl string
---@param print_prefix string|nil
function M.print(msg, hl, print_prefix)
  if not print_prefix then
    print_prefix = default_print_prefix
  end

  vim.api.nvim_echo(
    {{print_prefix, hl}, {msg}}, true, {}
  )
end

---output msg when verbose is true
---@param msg string
---@return nil
function M.debug(msg)
  if not option.options.verbose then
    return
  end

  local module_name =
    debug.getinfo(2, "S").source:match("([^/\\]+)%.lua$") or ""

  M.print(msg, "DebugMsg", "[" .. plugin_name .. "/" .. module_name .. "] ")
end

---@param msg string
---@return nil
function M.warn(msg)
  M.print(msg, "WarningMsg")
end

---@param msg string
---@return nil
function M.error(msg)
  M.print(msg, "ErrorMsg")
end

---get prefix for output message
---@return string
function M.get_message_prefix()
  return "[" .. plugin_name .. "]"
end

return M
