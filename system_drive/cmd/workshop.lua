local Screen, Window, Icon, UI = require("screen"), require("window"), require("icon"), require("ui")
local scrn, desktop
local winx, winy = 50, 11
local nextrefresh = 0

function _init()
  scrn = Screen:new("Homegirl Workshop", 11, 2)
  scrn:palette(0, 8, 8, 8)
  scrn:palette(1, 0, 0, 0)
  scrn:palette(2, 15, 15, 15)
  scrn:palette(3, 7, 11, 15)
  scrn:autocolor()

  desktop = scrn:attach("desktop", Icon.Board:new())
  scrn:step(0)
end

function _step(t)
  view.active(scrn.rootvp)
  scrn:step(t)
  if t > nextrefresh then
    local drives = fs.drives()
    table.sort(drives)
    for i, drive in ipairs(drives) do
      drives[drive .. ":"] = true
      if not desktop.children[drive .. ":"] then
        desktop:attach(drive .. ":", Icon:new(drive, iconfor(drive .. ":"))).onopen = onopen
      end
    end
    for name, child in pairs(desktop.children) do
      if not drives[name] then
        desktop:destroychild(name)
      end
    end
    for name, win in pairs(scrn.children) do
      local board = win.children["items"]
      if board then
        board = board.children["items"]
      end
      if board and #(board.children) > 0 and not view.focused(win.container) then
        board = nil
      end
      if board then
        local items = fs.list(name) or {}
        table.sort(items)
        for i, item in ipairs(items) do
          items[name .. item] = true
          if not board.children[name .. item] then
            board:attach(name .. item, Icon:new(notrailslash(item), iconfor(name .. item))).onopen = onopen
          end
        end
        for item, child in pairs(board.children) do
          if not items[item] then
            board:destroychild(item)
          end
        end
      end
    end
    nextrefresh = t + 1024
  end
end

function onopen(icon)
  local filename = icon.drop
  if fs.isdir(filename) then
    opendir(filename)
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

function opendir(filename)
  local sw, sh = view.size(scrn.rootvp)
  local win = scrn:attachwindow(filename, Window:new(basename(filename), winx, winy, sw / 2, sh / 2))
  win.resizable = true
  win.onclose = function()
    scrn:destroychild(filename)
  end
  local board = win:attach("items", UI.Scrollbox:new()):attach("items", Icon.Board:new())
  board.ondrop = function(self, drop)
    if not string.find(drop, "%:") then
      return nil
    end
    if not fs.rename(drop, filename .. basename(drop)) then
      fs.write(filename .. basename(drop), fs.read(drop))
    end
    nextrefresh = 0
    return Icon:new(basename(drop), iconfor(drop))
  end
  nextrefresh = 0

  winx = winx + 10
  winy = winy + 10
  if winx > sw / 2 then
    winx = 0
  end
  if winy > sh / 2 then
    winy = 1
  end
end

function iconfor(filename)
  if string.sub(filename, -1) == ":" then
    return _DRIVE .. "icons/drive.gif"
  elseif fs.isdir(filename) then
    return _DRIVE .. "icons/dir.gif"
  else
    local ext = ""
    if string.find(filename, "%.") then
      ext = string.lower(string.sub(filename, 1 - string.find(string.reverse(filename), "%.")))
    end
    if fs.isfile(_DRIVE .. "icons/" .. ext .. ".gif") then
      return _DRIVE .. "icons/" .. ext .. ".gif"
    end
  end
  return _DRIVE .. "icons/file.gif"
end

function basename(path)
  path = notrailslash(path)
  local i = string.find(string.reverse(path), "/") or string.find(string.reverse(path), ":") or #path
  return string.sub(path, -i + 1)
end

function trailslash(path)
  if string.sub(path, -1) == "/" then
    return path
  else
    return path .. "/"
  end
end
function notrailslash(path)
  if string.sub(path, -1) == "/" then
    return string.sub(path, 1, -2)
  else
    return path
  end
end
