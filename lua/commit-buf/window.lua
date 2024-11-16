local log = require("commit-buf.log")
local option = require("commit-buf.option")

local M = {}

---example
---columns_opened = {
---  [1] = {
---    "commit_buf",
---    "git_log",
---  },
---}
---@type table<integer, (git_key|"commit_buf")[]>
local columns_opened = {}

---@type table<float_key, table<string, any>>
local float_configs = {
  help = {
    height = 3,
    width = 80,
    title = "commit-buf help",
  }
}

---@type table<string, any>
local float_config_default = {
  relative = "editor",
  focusable = true,
  style = "minimal",
  border = "rounded",
}

---@alias win_handle integer
---@type table<git_key|float_key|"commit_buf", win_handle|nil>
---these handles could be nil, but should not be zero
local handles = {}

---@type boolean
local initialized = false

---@type table<git_key, table>
local local_opts = {
  git_diff_staged = {},
  git_log = {
    number = false,
  },
  git_show_head = {},
  git_staged_file_list = {},
}

---@alias vim_win_opt string
---@type table<vim_win_opt, any>
local local_opts_default = {
  list = false,
  foldenable = false,
}

---@type table<"height"|"width", integer>
local screen_size = {}

---run vim cmd on window specified by key
---@param key git_key
---@param cmd_str string
---@return nil
function M.run_vim_cmd(key, cmd_str)
  if not handles[key] then
    log.debug("run_vim_cmd(): window is not opened for " .. key)
    return
  end

  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(handles[key])
  vim.cmd(cmd_str)
  vim.api.nvim_set_current_win(cur_win)
end

---@param key git_key|"commit_buf"
---@return integer|nil
local function get_column_index(key)
  for i, column in ipairs(columns_opened) do
    for _, val in ipairs(column) do
      if key == val then
        return i
      end
    end
  end
  return nil
end

---@param key git_key
---@param base_key git_key|"commit_buf"
---@return boolean
local function alloc_below(key, base_key)
  if not handles[base_key] then
    log.debug(
      "alloc_below() failed: handle of base_key " .. base_key .. " is nil"
    )
    return false
  end

  local column_index = get_column_index(base_key)
  if column_index == nil then
    log.debug(
      "alloc_below(): get_column_index() failed for " .. base_key
    )
    return false
  end

  local row_count = #columns_opened[column_index]

  local min_height = option.options.window.min_height
  -- check if screen has enough height for new window
  if screen_size["height"] / (row_count + 1) < min_height then
    log.debug("alloc_below(): height not enough when allocating " .. key)
    return false
  end

  return true
end

---@param key git_key
---@param base_key git_key|"commit_buf"
---@return boolean
local function alloc_right(key, base_key)
  if not handles[base_key] then
    log.debug(
      "alloc_right() failed: handle of base_key " .. base_key .. " is nil"
    )
    return false
  end

  local column_count = #columns_opened

  local min_width = option.options.window.min_width
  -- check if screen has enough width for new column
  if screen_size["width"] / (column_count + 1) < min_width then
    log.debug("alloc_right(): width not enough when allocating " .. key)
    return false
  end

  return true
end

---@param key git_key
---@param config table<string, any>
---@return nil
local function open_git(key, config)
  local handle = vim.api.nvim_open_win(0, true, config)
  if handle == 0 then
    handles[key] = nil
    log.debug("open_git(): nvim_open_win() failed for " .. key)
    return
  end

  handles[key] = handle

  for k, v in pairs(local_opts_default) do
    vim.api.nvim_set_option_value(k, v, {win = handle})
  end

  for k, v in pairs(local_opts[key]) do
    vim.api.nvim_set_option_value(k, v, {win = handle})
  end
end

---@return boolean
local function verify_config()
  local keys = {}
  for i, column in ipairs(option.options.window.columns) do
    if i == 1 and column[1] ~= "commit_buf" then
      log.debug(
          "verify_config(): user configuration invalid at " ..
          "columns[1][1]. " ..
          "the initial leftupper window must be \"commit_buf\""
      )
      return false
    end
    if i > 1 and column[1] == "commit_buf" then
      log.debug(
          "verify_config(): user configuration invalid at " ..
          "columns[" .. i .. "][1] " ..
          "\"commit_buf\" must be the initial leftupper window"
      )
      return false
    end
    for j, key in ipairs(column) do
      for _, val in ipairs(keys) do
        if val == key then
          log.debug(
            "verify_config(): user configuration invalid at " ..
            "columns[" .. i .. "][" .. j .. "]. " ..
            "\"".. key .. "\" appeared second time"
          )
          return false
        end
      end
      table.insert(keys, key)
    end
  end
  return true
end

---@param key git_key
---@param base_key git_key|"commit_buf"
---@return nil
local function vsplit_right(key, base_key)
  if key == "commit_buf" then
    return
  end

  local alloc_succeeded = alloc_right(key, base_key)
  if not alloc_succeeded then
    log.debug("vsplit_right(): window allocation failed for " .. key)
    return
  end

  local config = {
    split = "right",
    win = handles[base_key],
  }
  open_git(key, config)
end

---@param key git_key
---@param base_key git_key|"commit_buf"
---@return nil
local function split_below(key, base_key)
  if key == "commit_buf" then
    return
  end

  local alloc_succeeded = alloc_below(key, base_key)
  if not alloc_succeeded then
    log.debug("split_below(): window allocation failed for " .. key)
    return
  end

  local config = {
    split = "below",
    win = handles[base_key],
  }
  open_git(key, config)
end

---close window by key
---if window is not existing, just return
---@param key git_key|float_key|"commit_buf"
---@return nil
function M.close(key)
  if key == "commit_buf" then
    return
  end
  if not handles[key] then
    return
  end
  vim.api.nvim_win_close(handles[key], true)
  handles[key] = nil
end

---@return nil
local function close_all()
  for _, column in ipairs(columns_opened) do
    for _, key in ipairs(column) do
      M.close(key)
    end
  end
end

---@param width integer
---@return nil
local function resize_column_width(column_index, width)
  for _, key in ipairs(columns_opened[column_index]) do
    vim.api.nvim_win_set_width(handles[key], width)
  end
end

---@param column_index integer
---@param height integer|nil
---@param excludes (git_key|nil)[]
---@return nil
local function resize_column_height(column_index, height, excludes)
  if height ~= nil then
    for _, key in ipairs(columns_opened[column_index]) do
        for _, exclude in ipairs(excludes) do
          if key == exclude then
            goto continue
          end
        vim.api.nvim_win_set_height(handles[key], height)
      end
      ::continue::
    end
  end
end

---@param key git_key
---@return nil
local function maximize_key(key)
  local min_height = option.options.window.min_height
  local min_width = option.options.window.min_width

  local column_index = get_column_index(key)
  for i, _ in pairs(columns_opened) do
    if i ~= column_index then
      resize_column_width(i, min_width)
    else
      resize_column_height(i, min_height, { key })
    end
  end
end

---@param column_key_large git_key
---@param column_key_small git_key
---@return nil
local function align_max_height(column_key_large, column_key_small)
  local column_index_large = get_column_index(column_key_large)
  if not column_index_large then
    log.debug("align_max_height(): get_column_index() failed for " .. column_key_large)
    return
  end
  local column_index_small = get_column_index(column_key_small)
  if not column_index_small then
    log.debug("align_max_height(): get_column_index() failed for " .. column_key_small)
    return
  end

  local min_height = option.options.window.min_height

  -- large row has more windows and requires more space for other windows
  -- calc max height based on large row
  resize_column_height(column_index_large, min_height, { column_key_large })
  local max_height =
    screen_size["height"] -
      (#columns_opened[column_index_large] - 1) * min_height

  -- calc height of other windows in small row
  local min_height_small = math.floor(
    (screen_size["height"] - max_height) /
      (#columns_opened[column_index_small] - 1)
  )
  resize_column_height(column_index_small, min_height_small, { "git_show_head" })

  vim.api.nvim_win_set_height(handles[column_key_large], max_height)
  vim.api.nvim_win_set_height(handles[column_key_small], max_height)
end

---@return nil
local function maximize_git_diff_and_show()
  if not handles["git_diff_staged"] then
    return
  end
  if not handles["git_show_head"] then
    maximize_key("git_diff_staged")
    return
  end

  local diff_column = get_column_index("git_diff_staged")
  local show_column = get_column_index("git_show_head")

  ---@cast diff_column integer
  ---@cast show_column integer
  if not diff_column or not show_column then
    log.debug("maximize_git_diff_and_show(): get_column_index() failed")
    return
  end

  local row_count_diff = #columns_opened[diff_column]
  local min_height = option.options.window.min_width
  local min_width = option.options.window.min_width
  local max_height

  if diff_column == show_column then
    -- same column
    -- minimize other window height
    -- set diff height to half of remaining
    resize_column_height(
      diff_column, min_height, { "git_diff_staged", "git_show_head" }
    )
    max_height = math.floor(
      (screen_size["height"] - (row_count_diff - 2) * min_height) / 2
    )
    vim.api.nvim_win_set_height(handles["git_diff_staged"], max_height)
    vim.api.nvim_win_set_height(handles["git_show_head"], max_height)

    -- minimize other column width
    -- diff column has max width when others have min width
    for i, _ in pairs(columns_opened) do
      if i ~= diff_column then
        resize_column_width(i, min_width)
      end
    end
  else -- if diff_column ~= show_column
    -- different column
    -- minimize other window height, but align height of git_diff and git_show
    local row_count_show = #columns_opened[show_column]
    if row_count_diff > row_count_show then
      align_max_height("git_diff_staged", "git_show_head")
    else
      align_max_height("git_show_head", "git_diff_staged")
    end

    -- minimize other column width
    for i, _ in pairs(columns_opened) do
      if i ~= diff_column and i ~= show_column then
        resize_column_width(i, min_width)
      end
    end
    -- allocate half of the remaining width to diff_column and show_column
    local max_width = math.floor(
      (screen_size["width"] - (#columns_opened - 2) * min_width) / 2
    )
    resize_column_width(diff_column, max_width)
    resize_column_width(show_column, max_width)
  end
end

---@return nil
function M.open()
  if not initialized then
    initialized = true
    handles["commit_buf"] = vim.api.nvim_get_current_win()
    screen_size["height"] = vim.api.nvim_win_get_height(handles["commit_buf"])
    screen_size["width"] = vim.api.nvim_win_get_width(handles["commit_buf"])
    columns_opened[1] = {
      "commit_buf",
    }
  end

  local is_config_valid = verify_config()
  if not is_config_valid then
    log.debug("open() failed: invalid user config")
    return
  end

  local base_key = "commit_buf"
  local pos = 1
  for i, column in ipairs(option.options.window.columns) do
    -- start from vsplit
    if i > 1 then
      local key = column[1]

      -- if verify_config() returns true, this key should not be "commit_buf"
      ---@cast key git_key
      if key == "commit_buf" then
        log.debug(
          "open() failed: unexpected error when opening \"" .. key .. "\""
        )
        close_all()
        return
      end
      vsplit_right(key, base_key)
      if handles[key] then
        pos = pos + 1
        columns_opened[pos] = {}
        table.insert(columns_opened[pos], key)
        base_key = key
      end
    end
  end

  local opened_column_index = 1
  for i, column in ipairs(option.options.window.columns) do
    -- do split for each column
    -- check if column top window is opened. if not, skip that column
    if not columns_opened[opened_column_index] then
      log.debug("open(): skip column starts from " .. column[1])
      goto continue
    end

    if column[1] ~= columns_opened[opened_column_index][1] then
      log.debug("open(): skip column starts from " .. column[1])
      goto continue
    end

    opened_column_index = opened_column_index + 1

    base_key = column[1]
    for j, key in ipairs(column) do
      -- for j == 1, window is already opened by vsplit_right() above
      if j > 1 then
        -- if verify_config() returns true, this key should not be "commit_buf"
        ---@cast key git_key
        if key == "commit_buf" then
          log.debug(
            "open() failed: unexpected error when opening \"" .. key .. "\""
          )
          close_all()
          return
        end
        split_below(key, base_key)
        if handles[key] then
          table.insert(columns_opened[i], key)
          base_key = key
        end
      end
    end
    ::continue::
  end

  maximize_git_diff_and_show()
end

---@param key float_key
---@return nil
function M.open_float(key)
  local config = vim.deepcopy(float_config_default, false)
  for k, value in pairs(float_configs[key]) do
    config[k] = value
  end

  local screen_center_upper_row = math.floor(
    math.max(
      screen_size["height"] - float_configs[key].height, 0
    ) / 2
  )
  local screen_center_left_column = math.floor(
    math.max(
      screen_size["width"] - float_configs[key].width, 0
    ) / 2
  )

  config["row"] = screen_center_upper_row
  config["col"] = screen_center_left_column

  local handle = vim.api.nvim_open_win(0, false, config)
  if handle == 0 then
    log.debug("open_float(): nvim_open_win() failed for " .. key)
    return
  end

  handles[key] = handle
end

---get window handle by key
---@param key git_key|float_key
---@return win_handle|nil #can be nil, but should not be zero
function M.get_handle(key)
  return handles[key]
end

---close window if dependent window is not opened
---@return nil
function M.close_if_dependent_win_not_opened()
  if not handles["git_diff_staged"] then
    M.close("git_show_head")
    M.close("git_staged_file_list")
  end
end

if _G.__COMMIT_BUF_TEST then
  ---mock function to set config for unit test
  ---@param columns table<integer, (git_key|"commit_buf")[]>
  ---@return nil
  function M.__mock_columns_opened(columns)
    columns_opened = vim.deepcopy(columns, false)
  end

  ---mock function to set handles for unit test
  ---@param f_handles table<git_key|"commit_buf", win_handle>
  ---@return nil
  function M.__mock_handles(f_handles)
    handles = vim.deepcopy(f_handles, false)
  end

  ---mock function to set screen_size
  ---@param height integer
  ---@param width integer
  ---@return nil
  function M.__mock_screen_size(height, width)
    screen_size["height"] = height
    screen_size["width"] = width
  end

  M.__alloc_below = alloc_below
  M.__alloc_right = alloc_right
  M.__get_column_index = get_column_index
  M.__verify_config = verify_config
end

return M
