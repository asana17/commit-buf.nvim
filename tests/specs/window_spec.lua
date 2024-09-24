local window = require("commit-buf.window")
describe("open()", function()
  it("window number increases", function()
    local initial_win_num = #vim.api.nvim_list_wins()

    window.open()

    local after_win_num = #vim.api.nvim_list_wins()
    vim.cmd("close")
    assert.are.equal(initial_win_num + 1, after_win_num)
  end)
end)
