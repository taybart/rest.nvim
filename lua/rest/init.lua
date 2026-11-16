local _MODULE = {} _MODULE._default_opts = {
no_wrap = true, 
code_actions = true, 


icon = {glyph = "󰒲", color = "#26afe5", cterm_color = "38"}
}

_MODULE.opts = {}

function _MODULE.setup(opts) if opts == nil then opts = {} end
  opts = vim.tbl_deep_extend("force", _MODULE._default_opts, opts)

  if opts.code_actions then
    require("rest/code_actions").register_code_actions()
  end
  _MODULE.register_icon()
end

--- registers the rest file icon (opts.icon) w/ nvim-web-devicons, for .rest
--- files and the rest filetype
function _MODULE.register_icon()
  local icon local __MIDNIGHT_TMP_1__ = _MODULE.opts icon = __MIDNIGHT_TMP_1__.icon
  if not icon then
    return
  end
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return
  end
  devicons.set_icon({
  rest = {
  icon = icon.glyph, 
  color = icon.color, 
  cterm_color = icon.cterm_color, 
  name = "Rest"
  }
  })
  devicons.set_icon_by_filetype({rest = "rest"})
end
return _MODULE
-- __MIDNIGHT_COMPILED__