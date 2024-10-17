local utils = require("commit-buf.utils")

describe("get_result_table()", function()
  it("echo hello", function()
    local cmd = { "echo", "hello" }
    local stdout_table, _ = utils.get_result_table(cmd, 0, 0, 100)
    local expected_table = { "hello" }
    for i = 1, #expected_table do
      assert.are.equal(stdout_table[i], expected_table[i])
    end
  end)
  it("ls with nonexisitent directory", function()
    local cmd = { "ls", "nonexistent_directory" }
    local _, stderr_table = utils.get_result_table(cmd, 0, 0, 100)
    local expected_table = {
      "ls: cannot access 'nonexistent_directory': No such file or directory"
    }
    for i = 1, #expected_table do
      assert.are.equal(stderr_table[i], expected_table[i])
    end
  end)
end)

describe("is_result_table_empty()", function()
  it("empty table", function()
    local table = {"", "", ""}
    assert(utils.is_result_table_empty(table))
  end)
  it("non-empty table", function()
    local table = {"", "hello", ""}
    assert(not utils.is_result_table_empty(table))
  end)
end)
