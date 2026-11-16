local _MODULE = {} _MODULE.registered = false

function _MODULE.register_code_actions()
  local has, code_actions = pcall(require, "code-actions")
  if not has or _MODULE.registered then
    return
  end
  code_actions.add_server({
  name = "rest.nvim", 
  filetypes = {include = {"rest"}}, 

  actions = {
  {
  command = "Execute block under cursor", 
  show = function() return require("rest/execute").block_label_under_cursor() ~= nil end, 
  fn = function() return require("rest/execute").block_under_cursor() end
  }, 
  {
  command = "Pick label to run", 
  fn = function() return require("rest/execute").do_labels() end
  }
  }
  })
  _MODULE.registered = true
end
return _MODULE
-- __MIDNIGHT_COMPILED__