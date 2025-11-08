local M = {}

function M.register_code_actions()
  local has_code_actions = pcall(require, "code-actions")
  if not has_code_actions then
    return
  end
  require("code-actions").setup({
    register_keymap = false,
    name = "rest.nvim",
    filetype = {
      include = { "rest" },
    },
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
end

return M
