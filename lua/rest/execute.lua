local M = {
  surrogate_language = 'hcl',
  parsed_query = nil,
}
local ui = require('rest.ui')
function M.register_ts_query()
  vim.treesitter.language.register('rest', M.surrogate_language)

  local query = [[
    (block
      (identifier) @requests (#eq? @requests "request")
      (string_lit) @label
    ) @block
  ]]
  local success, parsed_query = pcall(function()
    return vim.treesitter.query.parse(M.surrogate_language, query)
  end)
  -- always restore ts language
  vim.treesitter.language.register(M.surrogate_language, M.surrogate_language)
  if not success then
    error('ts query parse failure')
    return nil
  end
  M.parsed_query = parsed_query
end

function M.do_labels()
  local parsers = require('nvim-treesitter.parsers')

  local parser = parsers.get_parser(0, M.surrogate_language)
  local root = parser:parse()[1]:root()
  local start_row, _, end_row, _ = root:range()
  local labels = {}
  for i, node in M.parsed_query:iter_captures(root, 0, start_row, end_row) do
    local name = M.parsed_query.captures[i]
    if name == 'label' then
      local label = vim.treesitter.get_node_text(node, 0)
      label = label:gsub('"(.*)"', '%1')
      table.insert(labels, label)
    end
  end
  if #labels == 0 then
    vim.notify('no request blocks found', vim.log.levels.WARN)
    return
  end
  ui.choose({ title = 'what should we run?' }, labels, function(label)
    M.run({ type = 'label', label = label })
  end)
end

function M.block_under_cursor()
  local ts_query = require('nvim-treesitter.query')
  local parsers = require('nvim-treesitter.parsers')
  local locals = require('nvim-treesitter.locals')

  local surrogate_language = 'hcl'

  vim.treesitter.language.register('rest', surrogate_language)
  local query = [[(block (identifier) @requests (#eq? @requests "request")) @block]]
  local success, parsed_query = pcall(function()
    return vim.treesitter.query.parse(surrogate_language, query)
  end)
  if not success or not parsed_query then
    error('ts query parse failure')
    return nil
  end

  local parser = parsers.get_parser(0, surrogate_language)
  local root = parser:parse()[1]:root()
  local start_row, _, end_row, _ = root:range()
  local block_num = -1
  local did_execute = false
  for match in ts_query.iter_prepared_matches(parsed_query, root, 0, start_row, end_row) do
    locals.recurse_local_nodes(match, function(_, node)
      if node:type() == 'block' then
        block_num = block_num + 1
        local c_row = unpack(vim.api.nvim_win_get_cursor(0)) - 1
        local s_row, _, e_row, _ = vim.treesitter.get_node_range(node)
        if c_row >= s_row and c_row <= e_row then
          M.run({ type = 'block', block = block_num })
          did_execute = true
          return
        end
      end
    end)
  end
  if not did_execute then
    print('no block under cursor')
  end
end

function M.file()
  M.run({ type = 'file' })
end

function M.block(args)
  local label = args.fargs[1]
  if label ~= nil then
    M.run({ type = 'label', label = label })
    return
  end
  M.block_under_cursor()
end

function M.run_cmd(args)
  local cmd = { 'rest', '-nc', '-f', vim.fn.expand('%') }

  local add_args = {
    ['block'] = function(a)
      table.insert(cmd, '-b')
      table.insert(cmd, a.block)
    end,
    ['label'] = function(a)
      table.insert(cmd, '-l')
      table.insert(cmd, a.label)
    end,
    ['file'] = function() end,
    ['export'] = function(a)
      table.insert(cmd, '-e')
      table.insert(cmd, a.language)
      if a.client then
        table.insert(cmd, '-c')
      end
    end,
    ['list-languages'] = function()
      table.insert(cmd, '-e')
      table.insert(cmd, 'ls')
    end,
  }
  add_args[args.type](args)

  --- @diagnostic disable-next-line: undefined-field
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr .. result.stdout, vim.log.levels.ERROR)
    return
  end
  return result.stdout
end

function M.run(args)
  local result = M.run_cmd(args)
  if not result then
    return
  end
  ui.show_result(result, {
    -- ['Y'] = {
    --   description = 'Copy result',
    --   callback = function()
    --     vim.fn.setreg('+', result)
    --     vim.notify('Copied to clipboard')
    --   end,
    -- },
  })
end

function M.export_language(lang)
  local client = M.run_cmd({
    type = 'export',
    language = lang,
    client = true,
  })
  if not client then
    return
  end
  vim.fn.setreg('+', client)
  vim.notify('copied to clipboard')
end

function M.export(args)
  if args.fargs[1] then
    M.export_language(args.fargs[1])
    return
  end
  local result = M.run_cmd({ type = 'list-languages' })
  if not result then
    return
  end
  local output = vim.split(result, '\n', { plain = true })
  -- remove blank entries
  for i, v in ipairs(output) do
    if v == '' then
      table.remove(output, i)
    end
  end
  vim.ui.select(output, {
    prompt = 'export to:',
    prompt_chars = '>',
  }, function(choice)
    M.export_language(choice)
  end)
end

return M
