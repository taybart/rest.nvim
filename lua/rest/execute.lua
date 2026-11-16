local _MODULE = {} _MODULE.parsed_query = nil

function _MODULE.register_ts()
  local query = 
  "    (block\n      (identifier) @requests (#eq? @requests \"request\")\n      (string_lit) @label\n    ) @block\n  "




  local ok, parsed_query = pcall(
  function() return vim.treesitter.query.parse("hcl", query) end)

  if not ok then
    error("ts query parse failure" .. parsed_query)
    return nil
  end
  _MODULE.parsed_query = parsed_query
end

function _MODULE.do_labels()
  local parser = vim.treesitter.get_parser(0, "hcl")
  if not parser then
    error("no hcl parser found")
    return
  end
  local root = parser:parse()[1]:root()
  local start_row, _, end_row, _ = root:range()
  local labels = {}
  for i, node in _MODULE.parsed_query:iter_captures(root, 0, start_row, end_row) do
    local name = _MODULE.parsed_query.captures[i]
    if name == "label" then
      local label = vim.treesitter.get_node_text(node, 0)
      label = label:gsub("\"(.*)\"", "%1")
      table.insert(labels, label)
    end
  end
  if #labels == 0 then
    vim.notify("no request blocks found", vim.log.levels.WARN)
    return
  end

  require("rest.ui").choose({title = "what should we run?"}, labels, function(label)
    if not label then return end
    _MODULE.run({type = "label", label = label})
  end)
end

function _MODULE.block_under_cursor()
  local label = _MODULE.block_label_under_cursor()
  if label then
    _MODULE.run({type = "label", label = label})
    return
  end
  print("no block under cursor")
end

function _MODULE.block_label_under_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1


  local parser = vim.treesitter.get_parser(buf, "hcl")
  if not parser then
    error("No parser available for hcl")
    return nil
  end

  local root = parser:parse()[1]:root()


  local node = root:descendant_for_range(row, col, row, col)
  if not node then return nil end


  local current = node
  while current do
    if current:type() == "block" then


      local label = nil
      for child in current:iter_children() do
        if child:type() == "string_lit" then
          label = vim.treesitter.get_node_text(child, buf)

          label = label:gsub("\"", "")
          break
        end
      end
      return label
    end
    current = current:parent()
  end

  return nil
end

function _MODULE.file() _MODULE.run({type = "file"}) end

function _MODULE.block(args)
  local label = args.fargs[1]
  if label ~= nil then
    _MODULE.run({type = "label", label = label})
    return
  end
  _MODULE.block_under_cursor()
end

function _MODULE.run_cmd(args)
  local cmd = {"rest", "--flags", "-nc", "-f", vim.fn.expand("%")}

  local add_args = {
  block = function(a)
    table.insert(cmd, "-b")
    table.insert(cmd, a.block)
  end, 
  label = function(a)
    table.insert(cmd, "-l")
    table.insert(cmd, a.label)
  end, 
  file = function() end, 
  export = function(a)
    table.insert(cmd, "-e")
    table.insert(cmd, a.language)
    if a.client then table.insert(cmd, "-c") end
  end, [
  "list-languages"] = function()
    table.insert(cmd, "-e")
    table.insert(cmd, "ls")
  end
  }
  add_args[args.type](args)

  --- @diagnostic disable-next-line: undefined-field
  local result = vim.system(cmd, {text = true}):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr .. result.stdout, vim.log.levels.ERROR)
    return
  end
  return result.stdout
end

function _MODULE.run(args)
  local result = _MODULE.run_cmd(args)
  if not result then return end
  require("rest.ui").show_result(result, {
  Y = {
  description = "Copy result", 
  callback = function()
    vim.fn.setreg("+", result)
    vim.notify("Copied to clipboard")
  end
  }
  })
end

function _MODULE.export_language(lang)
  local client = _MODULE.run_cmd({
  type = "export", 
  language = lang, 
  client = true
  })
  if not client then return end
  vim.fn.setreg("+", client)
  vim.notify("copied to clipboard")
end

function _MODULE.export(args)
  if args.fargs[1] then
    _MODULE.export_language(args.fargs[1])
    return
  end
  local result = _MODULE.run_cmd({type = "list-languages"})
  if not result then return end
  local output = vim.split(result, "\n", {plain = true})

  for i, v in ipairs(output) do
    if v == "" then table.remove(output, i) end
  end
  vim.ui.select(output, {
  prompt = "export to:", 
  prompt_chars = ">"
  }, function(choice) return _MODULE.export_language(choice) end)
end
return _MODULE
-- __MIDNIGHT_COMPILED__