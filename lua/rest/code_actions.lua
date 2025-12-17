local M = {
  registered = false,
}

function M.register_code_actions()
  local has, code_actions = pcall(require, "code-actions")
  if not has or M.registered then
    return
  end
  code_actions.add_server({
    name = "rest.nvim",
    filetypes = { include = { "rest" } },
    -- stylua: ignore
    actions = {
      {
        command = 'Execute block under cursor',
        show = function() return require("rest/execute").block_label_under_cursor() ~= nil end,
        fn = function() require("rest/execute").block_under_cursor() end,
      },
      {
        command = 'Pick label to run',
        fn = function() require('rest/execute').do_labels() end,
      },
    },
  })
  M.registered = true
end

return M
