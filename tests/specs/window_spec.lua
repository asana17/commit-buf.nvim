_G.__COMMIT_BUF_TEST = true

local option = require("commit-buf.option")
local window = require("commit-buf.window")

local configs = {
  window = {
    columns = {},
    min_height = 1,
    min_width = 1,
  },
  verbose = true,
}

describe("get_column_index()", function()
  local columns = {
    [1] = {
      "commit_buf",
      "git_log",
    },
    [2] = {
      "git_diff_staged",
    },
  }
  window.__mock_columns_opened(columns)
  it("index can be achieved", function()
    local diff_index = window.__get_column_index("git_diff_staged")
    assert.are.equal(diff_index, 2)
  end)
  it("index should be nil if key does not exist in table", function()
    local show_index = window.__get_column_index("git_show_head")
    assert.are.equal(show_index, nil)
  end)
end)

describe("verify_config()", function()
  it("valid config", function()
    configs.window.columns = {
      [1] = {
        "commit_buf",
        "git_log",
      },
      [2] = {
        "git_show_file_list",
      },
      [3] = {
        "git_show",
        "git_diff_staged",
      },
    }
    option.setup(configs)
    assert.is["true"](window.__verify_config())
  end)
  it("invalid config: commit_buf is not leftupper", function()
    configs.window.columns = {
      [1] = {
        "git_log",
      },
      [2] = {
        "commit_buf",
        "git_show_file_list",
      },
      [3] = {
        "git_show",
        "git_diff_staged",
      },
    }
    option.setup(configs)
    assert.is["false"](window.__verify_config())
  end)
  it("invalid config: same key more than once", function()
    configs.window.columns = {
      [1] = {
        "commit_buf",
        "git_log",
      },
      [2] = {
        "git_show_file_list",
        "git_log",
      },
      [3] = {
        "git_show",
        "git_diff_staged",
      },
    }
    option.setup(configs)
    assert.is["false"](window.__verify_config())
  end)
end)

describe("alloc_below()", function()
  configs.window.min_height = 15
  configs.window.min_width = 1

  option.setup(configs)
  window.__mock_screen_size(100, 1)
  local columns = {
    [1] = {
      "commit_buf",
      "git_log",
    }
  }
  window.__mock_columns_opened(columns)

  it("should fail if base window is not opened", function()
    assert.is["false"](window.__alloc_below("git_show_head", "git_diff_staged"))
  end)


  local handles = {
    commit_buf =  2415,
    git_log= 3252
  }
  window.__mock_handles(handles)

  it("should succeed when screen height is enough", function()
    assert.is["true"](window.__alloc_below("git_diff_staged", "git_log"))
  end)

  window.__mock_screen_size(20, 1)

  it("should fail when screen height is not enough", function()
    assert.is["false"](window.__alloc_below("git_diff_staged", "git_log"))
  end)
end)

describe("alloc_right()", function()
  configs.window.min_height = 1
  configs.window.min_width = 80

  option.setup(configs)
  window.__mock_screen_size(1, 500)

  it("should fail if base window is not opened", function()
    assert.is["false"](window.__alloc_right("git_show_head", "git_diff_staged"))
  end)

  local columns = {
    [1] = {
      "commit_buf",
    },
    [2] = {
      "git_log",
    }
  }
  window.__mock_columns_opened(columns)

  local handles = {
    commit_buf =  2415,
    git_log= 3252
  }
  window.__mock_handles(handles)

  it("should succeed when screen width is enough", function()
    assert.is["true"](window.__alloc_right("git_diff_staged", "git_log"))
  end)

  window.__mock_screen_size(1, 200)

  it("should fail when screen width is not enough", function()
    assert.is["false"](window.__alloc_right("git_diff_staged", "git_"))
  end)
end)
