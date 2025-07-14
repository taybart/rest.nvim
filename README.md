# Rest

Neovim support for [rest](https://github.com/taybart/rest)

### Installation

Depends on: [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

### Commands

```vim
:ExecuteBlock [block number]
:ExecuteBlockUnderCursor
:ExecuteFile [file name]
:Export [language name]
```

### Keymaps

the default keymaps are:

```lua
      vim.keymap.set('n', '<c-l>', execute.do_labels, {}) -- pick
      vim.keymap.set('n', '<c-e>', execute.block_under_cursor, {})
      vim.keymap.set('n', '<c-t>', execute.file, {})
```
