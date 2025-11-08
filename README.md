# Rest

Neovim support for [rest](https://github.com/taybart/rest)

### Installation

Depends on: [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

```lua
{
    'taybart/rest.nvim',
    -- optional dependency that will add code actions in rest files
    dependencies = { 'taybart/code-actions.nvim' },
    opts = {
        -- add no wrap to rest files
        no_wrap = true,
        -- set to false to prevent code action registration
        -- you do not need to set this to false if you do 
        -- not add code actions as a dependency
        code_actions = true,
    },
}
```

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
