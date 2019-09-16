function _init(args)
  local line = ""
  list = fs.list(args[1])
  if not list then
    print("Could not list '" .. (args[1] or fs.cd()) .. "'")
    return sys.exit(1)
  end
  table.sort(list)
  for i, entry in pairs(list) do
    if string.sub(entry, -1) == "/" then
      print("     " .. string.sub(entry, 0, -2) .. " (dir)")
    end
  end
  for i, entry in pairs(list) do
    if string.sub(entry, -1) ~= "/" then
      if line == "" then
        line = line .. "  " .. entry
      else
        while #line < 35 do
          line = line .. " "
        end
        print(line .. entry)
        line = ""
      end
      if #line >= 35 then
        print(line)
        line = ""
      end
    end
  end
  if line ~= "" then
    print(line)
  end
end
