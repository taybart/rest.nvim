local M = {}
local rest_cmd = '!rest -nc'

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
  if not success then
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
          vim.cmd(rest_cmd .. [[ -f % -b ]] .. block_num)
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
  vim.cmd(rest_cmd .. [[ -f % ]])
end

function M.block(args)
  local label = args.fargs[1]
  -- execute the label if given
  if label ~= nil then
    vim.cmd(rest_cmd .. [[ -f % -l ]] .. label)
    return
  end
  M.block_under_cursor()
end

return M
