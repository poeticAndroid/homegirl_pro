wdays = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"}
months = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"}
function _init(args)
  print("Filename: " .. args[1])
  size = fs.size(args[1])
  print("Size: " .. friendly(size))
  th, tm, ts, tu = fs.time(args[1])
  dy, dm, dd, dw = fs.date(args[1])
  print(
    string.format(
      "Modified: %d-%s-%02d %s %d:%02d:%02d UTC%+gh",
      dy,
      months[dm],
      dd,
      wdays[dw + 1],
      th,
      tm,
      ts,
      tu / 60
    )
  )
end

function friendly(bytes)
  local units = bytes
  local measures = {"YiB", "ZiB", "EiB", "PiB", "TiB", "GiB", "MiB", "KiB"}
  local measure = "bytes"
  while units >= 1024 do
    units = units / 1024
    measure = table.remove(measures) .. " (" .. bytes .. " bytes)"
  end
  return string.format("%4.3f", units) .. " " .. measure
end
