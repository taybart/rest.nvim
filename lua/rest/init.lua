local M = {
  _default_opts = {
    no_wrap = true,
    code_actions = true,
  },
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M._default_opts, opts)
  -- register in setup so we can make sure lazy loads tb/c-a
  if M.opts.code_actions then
    require("rest/code_actions").register_code_actions()
  end
end

return M
