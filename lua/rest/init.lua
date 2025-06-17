local M = {}

local execute = require('rest.execute')

local function has_plenary()
  local exists, _ = pcall(require, 'plenary')
  return exists
end

function M.setup()
  local group = 'taybart.rest'

  vim.filetype.add({ extension = { rest = 'hcl' } })
  execute.register_ts_query()

  vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = group,
    pattern = '*.rest',
    callback = function()
      vim.bo.commentstring = '# %s'

      vim.api.nvim_create_user_command('ExecuteBlock', execute.block, { nargs = '?' })
      vim.api.nvim_create_user_command(
        'ExecuteBlockUnderCursor',
        execute.block_under_cursor,
        { nargs = '?' }
      )
      vim.api.nvim_create_user_command('ExecuteFile', execute.file, {})
      vim.api.nvim_create_user_command('Export', execute.export, { nargs = '?' })

      vim.keymap.set('n', '<c-c>', '<cmd>Export curl<cr>', {})
      vim.keymap.set('n', '<c-e>', execute.block_under_cursor, {})
      vim.keymap.set('n', '<c-l>', execute.do_labels, {})
      vim.keymap.set('n', '<c-t>', execute.file, {})
    end,
  })

  if has_plenary() then
    require('plenary.filetype').add_file('rest')
  end
end

return M
