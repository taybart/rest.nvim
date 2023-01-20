local M = {}

local execute = require('rest.execute')

function M.setup()
  local group = 'taybart.rest'

  vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd('BufRead,BufNewFile', {
    group = group,
    pattern = '*.rest',
    callback = function()
      vim.opt.filetype = 'hcl'

      vim.api.nvim_create_user_command('ExecuteBlock', execute.block, { nargs = '?' })
      vim.api.nvim_create_user_command(
        'ExecuteBlockUnderCursor',
        execute.block_under_cursor,
        { nargs = '?' }
      )
      vim.api.nvim_create_user_command('ExecuteFile', execute.file, {})

      vim.keymap.set('n', '<c-e>', execute.block_under_cursor, {})
      vim.keymap.set('n', '<c-t>', execute.file, {})
    end,
  })
end

return M
