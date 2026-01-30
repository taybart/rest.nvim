-- local rest = require("rest")
-- if rest.opts.no_wrap then
vim.opt_local.wrap = false
-- end

require('nvim-treesitter').install('hcl')
vim.treesitter.start(0, 'hcl')

local execute = require('rest/execute')
execute.register_ts()

vim.api.nvim_create_user_command('ExecuteBlock', execute.block, { nargs = '?' })
vim.api.nvim_create_user_command('ExecuteBlockUnderCursor', execute.block_under_cursor, {})
vim.api.nvim_create_user_command('ExecuteFile', execute.file, {})
vim.api.nvim_create_user_command('Export', execute.export, { nargs = '?' })

vim.keymap.set('n', '<c-e>', execute.block_under_cursor, {})
vim.keymap.set('n', '<c-l>', execute.do_labels, {})
vim.keymap.set('n', '<c-t>', execute.file, {})
