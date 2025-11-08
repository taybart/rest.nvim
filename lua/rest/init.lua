local M = {
  _default_opts = {
    no_wrap = true,
    code_actions = true,
  },
}

local execute = require("rest/execute")
local code_actions = require("rest/code_actions")

function M.get_cursor_label()
  return execute.block_label_under_cursor()
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M._default_opts, opts)
  -- vim.filetype.add({ extension = { rest = 'hcl' } })
  vim.filetype.add({ extension = { rest = "rest" } })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "rest",
    callback = function()
      vim.api.nvim_set_option_value("syntax", "hcl", {})
      if M.opts.no_wrap then
        vim.opt_local.wrap = false
      end
    end,
  })
  execute.register_ts_query()
  if M.opts.code_actions then
    code_actions.register_code_actions()
  end

  local group_id = vim.api.nvim_create_augroup("taybart.rest", {})
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = group_id,
    pattern = "*.rest",
    callback = function()
      vim.api.nvim_create_user_command("ExecuteBlock", execute.block, { nargs = "?" })
      vim.api.nvim_create_user_command("ExecuteBlockUnderCursor", execute.block_under_cursor, {})
      vim.api.nvim_create_user_command("ExecuteFile", execute.file, {})
      vim.api.nvim_create_user_command("Export", execute.export, { nargs = "?" })

      vim.keymap.set("n", "<c-e>", execute.block_under_cursor, {})
      vim.keymap.set("n", "<c-l>", execute.do_labels, {})
      vim.keymap.set("n", "<c-t>", execute.file, {})
    end,
  })
end

return M
