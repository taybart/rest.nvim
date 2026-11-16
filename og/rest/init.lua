local M = {
  _default_opts = {
    no_wrap = true,
    code_actions = true,
    -- the .rest file icon, registered w/ nvim-web-devicons (if it's installed),
    -- where snacks, lualine, oil, ... get file icons from (false: don't)
    icon = { glyph = "󰒲", color = "#26afe5", cterm_color = "38" },
  },
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M._default_opts, opts or {})
  -- register in setup so we can make sure lazy loads tb/c-a
  if M.opts.code_actions then
    require("rest/code_actions").register_code_actions()
  end
  M.register_icon()
end

--- registers the rest file icon (opts.icon) w/ nvim-web-devicons, for .rest
--- files and the rest filetype
function M.register_icon()
  local icon = M.opts.icon
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
      name = "Rest", -- (its highlight group is DevIconRest)
    },
  })
  devicons.set_icon_by_filetype({ rest = "rest" })
end

return M
