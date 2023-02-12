local M = {}

local execute = require('rest.execute')

local function has_plenary()
  local exists, _ = pcall(require, 'plenary')
  return exists
end

function M.setup()
  local group = 'taybart.rest'

  vim.filetype.add({ extension = { rest = 'hcl' } })

  vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd('BufRead,BufNewFile', {
    group = group,
    pattern = '*.rest',
    callback = function()
      -- vim.opt.filetype = 'hcl'

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

  if has_plenary() then
    require('plenary.filetype').add_file('rest')
  end
end

return M
