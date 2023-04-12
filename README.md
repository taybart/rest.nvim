# Rest

Neovim support for [rest](https://github.com/taybart/rest)

### Keymaps

  the default keymaps are:
    
```lua
      vim.keymap.set('n', '<c-e>', execute.block_under_cursor, {})
      vim.keymap.set('n', '<c-t>', execute.file, {})
```
