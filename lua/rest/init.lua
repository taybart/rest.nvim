local M = {}

local execute = require('rest.execute')

function M.setup()
  -- vim.filetype.add({ extension = { rest = 'hcl' } })
  vim.filetype.add({ extension = { rest = 'rest' } })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'rest',
    callback = function()
      vim.api.nvim_set_option_value('syntax', 'hcl', {})
    end,
  })
  execute.register_ts_query()

  local group_id = vim.api.nvim_create_augroup('taybart.rest', {})
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = group_id,
    pattern = '*.rest',
    callback = function()
      vim.api.nvim_create_user_command('ExecuteBlock', execute.block, { nargs = '?' })
      vim.api.nvim_create_user_command('ExecuteBlockUnderCursor', execute.block_under_cursor, {})
      vim.api.nvim_create_user_command('ExecuteFile', execute.file, {})
      vim.api.nvim_create_user_command('Export', execute.export, { nargs = '?' })

      vim.keymap.set('n', '<c-e>', execute.block_under_cursor, {})
      vim.keymap.set('n', '<c-l>', execute.do_labels, {})
      vim.keymap.set('n', '<c-t>', execute.file, {})
    end,
  })
end

return M
