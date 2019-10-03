local Window, Icon, UI, path = require("window"), require("icon"), require("ui"), require("path")
local win, dirname, focused

function _init(args)
  dirname = path.trailslash(path.resolve(fs.cd(), args[1]))
  local sw, sh = view.size(nil)
  local x, y = 64, 1
  local drives = fs.drives()
  local segs = path.split(dirname)
  table.sort(drives)
  while #drives > 0 and string.lower(drives[1] .. ":") ~= string.lower(segs[1]) do
    if x >= 10 then
      x = x - 10
    end
    y = y + 20
    table.remove(drives, 1)
  end
  x = x + #segs * 32
  y = y + #segs * 10
  win = Window:new(path.basename(dirname), x, y, sw / 2, sh / 2)
  win:icon(iconfor(dirname))
  win.resizable = true
  win.onclose = function()
    sys.exit()
  end
  view.size(win._resbtn, 11, 11)
  local board = win:attach("items", UI.Scrollbox:new()):attach("items", Icon.Board:new())
  board.ondrop = function(self, drop)
    if not string.find(drop, "%:") then
      return nil
    end
    if fs.rename(drop, dirname .. path.basename(drop)) then
      if fs.isfile(path.notrailslash(drop) .. ".gif") then
        fs.rename(path.notrailslash(drop) .. ".gif", dirname .. path.basename(drop) .. ".gif")
      end
    else
      sys.exec(_DRIVE .. "cmd/copy.lua", {drop, dirname})
      if fs.isfile(path.notrailslash(drop) .. ".gif") then
        fs.write(dirname .. path.basename(drop) .. ".gif", fs.read(path.notrailslash(drop) .. ".gif"))
      end
    end
    return Icon:new(path.basename(drop), iconfor(drop))
  end
  refresh()
  sys.stepinterval(-1)
end

function _step(t)
  win:step(t)
  view.active(win.mainvp)
  if input.hotkey() == "r" then
    refresh()
  end
  if focused ~= view.focused(win.container) then
    refresh()
  end
  focused = view.focused(win.container)
  sys.stepinterval(sys.stepinterval() * -1)
end

function refresh()
  local board = win.children["items"].children["items"]
  local items = fs.list(dirname) or {}
  local iconsonly = listhasicons(items)
  table.sort(items)
  for i, item in ipairs(items) do
    local filename = dirname .. item
    local show = not iconsonly
    if fs.isfile(path.notrailslash(filename) .. ".gif") then
      show = true
    end
    if string.sub(filename, -10) == ":drive.gif" then
      show = false
    end
    if
      string.sub(filename, -4) == ".gif" and
        (fs.isfile(string.sub(filename, 1, -5)) or fs.isdir(string.sub(filename, 1, -5)))
     then
      show = false
    end
    if show then
      items[filename] = true
      if not board.children[filename] then
        board:attach(filename, Icon:new(path.notrailslash(item), iconfor(filename))).onopen = onopen
      end
    end
  end
  for item, child in pairs(board.children) do
    if not items[item] then
      board:destroychild(item)
    end
  end
end

function onopen(icon)
  local filename = icon.drop
  if fs.isdir(filename) then
    sys.exec(_DRIVE .. "cmd/open.lua", {filename})
  else
    local ext = ""
    if string.find(filename, "%.") then
      ext = string.lower(string.sub(filename, 1 - string.find(string.reverse(filename), "%.")))
    end
    if ext == "lua" then
      sys.exec(filename)
    elseif ext == "gif" then
      sys.exec(_DRIVE .. "cmd/show.lua", {filename})
    elseif ext == "wav" then
      sys.exec(_DRIVE .. "cmd/play.lua", {filename})
    else
      sys.exec(_DRIVE .. "cmd/edit.lua", {filename})
    end
  end
end

function listhasicons(list)
  local seen = {}
  for i, item in ipairs(list) do
    seen[path.notrailslash(item)] = true
    if seen[path.notrailslash(item) .. ".gif"] then
      return true
    end
    if string.sub(item, -4) == ".gif" then
      if seen[string.sub(item, 1, -5)] then
        return true
      end
    end
  end
  return false
end

function iconfor(filename)
  if string.sub(filename, -1) == ":" then
    if fs.isfile(filename .. "drive.gif") then
      return filename .. "drive.gif"
    else
      return _DRIVE .. "icons/drive.gif"
    end
  elseif fs.isfile(path.notrailslash(filename) .. ".gif") then
    return path.notrailslash(filename) .. ".gif"
  elseif fs.isdir(filename) then
    return _DRIVE .. "icons/dir.gif"
  else
    local ext = "file"
    if string.find(filename, "%.") then
      ext = string.lower(string.sub(filename, 1 - string.find(string.reverse(filename), "%.")))
    end
    if fs.isfile(_DRIVE .. "icons/" .. ext .. ".gif") then
      return _DRIVE .. "icons/" .. ext .. ".gif"
    end
  end
  return _DRIVE .. "icons/file.gif"
end
