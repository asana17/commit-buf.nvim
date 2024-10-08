local utils = require("commit-buf.utils")
local window = require("commit-buf.window")
local key = "default"

describe("open()", function()
  it("buffer name specified correctly", function()
    window.open(key)
    local buffer_name = vim.api.nvim_buf_get_name(0)
    vim.cmd("close")
    assert.are.equal(buffer_name, utils.prefix_path(key))
  end)

  it("buffer is set to readonly", function()
    window.open(key)
    local read_only_opt = vim.api.nvim_get_option_value("readonly", { buf = 0 })
    vim.cmd("close")
    assert.are.equal(read_only_opt, true)
  end)
end)
