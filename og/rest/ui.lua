local M = {}

function M.choose(opts, choices, cb)
  if not opts.title then
    opts.title = 'Choose'
  end
  vim.ui.select(choices, {
    prompt = opts.title,
    format_item = function(s)
      return s
    end,
  }, function(choice)
    cb(choice)
  end)
end

function M.show_result(result, actions)
  -- check if result is blank, if so, just pop a notification
  if result:gsub('%s+', '') == '' then
    vim.notify('request sent')
    return
  end

  local output = vim.split(result, '\n', { plain = true })

  local lines = {}
  vim.list_extend(lines, output)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, #line)
  end
  width = math.min(width + 4, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' rest.nvim ',
    title_pos = 'center',
  })

  vim.api.nvim_set_option_value('cursorline', true, { win = win })
  vim.api.nvim_set_option_value('wrap', false, { win = win })

  -- vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Set up single-key actions
  for key, action in pairs(actions) do
    vim.keymap.set('n', key, function()
      close_window()
      action.callback(output)
    end, { buffer = buf, noremap = true, silent = true })
  end

  -- default exits
  vim.keymap.set('n', 'q', close_window, { buffer = buf })
  vim.keymap.set('n', '<Esc>', close_window, { buffer = buf })
  vim.keymap.set('n', '<CR>', close_window, { buffer = buf })

  local ns = vim.api.nvim_create_namespace('rest-result')

  vim.hl.range(buf, ns, 'Title', { 0, 0 }, { 0, -1 })
  for i = 2, #actions + 2 do
    vim.hl.range(buf, ns, 'Special', { i, 0 }, { i, 3 })
  end

  return win, buf
end

return M
