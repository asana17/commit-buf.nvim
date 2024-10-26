# commit-buf.nvim

Attach supporting window when editing commit message within `git commit`.

This plugin is inspired by [rhysd/commitia.vim](https://github.com/rhysd/committia.vim).

## Installation

* `lazy.nvim`

  ```lua
  local plugins = {
    {"asana17/commit-buf.nvim"},
  }

  require("commit-buf.nvim").setup()
  ```

  Or you can use the local one. If you use the following command, make sure
  this repo is installed under `~/`.

  ```lua
  local plugins = {
    {"commit-buf.nvim", dir = "~/commit-buf.nvim"},
  }

  require("commit-buf.nvim").setup()
  ```

## Configuration

### default

  ```lua
  local config = {
    window = {
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

  require("commit-buf.nvim").setup(config)
  ```

### Change window layout

Windows are allocated using the column list `windows.columns`. For example,
the default lists represents the following layout:

```text
|------------------------|------------------------|
|                        |                        |
|     "commit_buf"       |                        |
|                        |    "git_show_head"     |
|------------------------|                        |
|                        |                        |
| "git_staged_file_list" |------------------------|
|                        |                        |
|------------------------|                        |
|                        |    "git_diff_staged"   |
|      "git_log"         |                        |
|                        |                        |
|------------------------|------------------------|
```

`git_show_head` and `git_diff_staged` will be aligned and maximized
automatically.

If you pass the following `windows.columns` configuration, then the window
layout will be like the below image.

```lua
window = {
  columns = {
    [1] = {
      "commit_buf",
      "git_show_head",
    },
    [2] = {
      "git_log",
      "git_staged_file_list",
      "git_diff_staged",
    },
  },
}
```

```text
|------------------------|------------------------|
|                        |      "git_log"         |
|      "commit_buf"      |------------------------|
|                        | "git_staged_file_list" |
|------------------------|------------------------|
|                        |                        |
|                        |                        |
|    "git_show_head"     |    "git_diff_staged"   |
|                        |                        |
|                        |                        |
|------------------------|------------------------|
```

## Test

Use [`tests/minimal_init.lua`](tests/minimal_init.lua) to check.

```bash
nvim --headless --noplugin -u tests/minimal_init.lua -c \
  "PlenaryBustedDirectory tests {minimal_init = 'tests/minimal_init.lua'}"
```

## Before commit

Use `pre-commit`. Follow the [official Quick start][1].

```bash
pre-commit install -t pre-commit -t commit-msg
```

Use [Conventional Commits][2].

[1]: https://pre-commit.com/index.html#quick-start
[2]: https://www.conventionalcommits.org/en/v1.0.0/
