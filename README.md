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
