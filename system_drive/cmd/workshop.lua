local Screen, Window, Icon = require("screen"), require("window"), require("icon")
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
        desktop:attach(drive .. ":", Icon:new(drive .. ":", iconfor(drive .. ":"))).onopen = onopen
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
        local items = fs.list(name)
        table.sort(items)
        for i, item in ipairs(items) do
          items[name .. item] = true
          if not board.children[name .. item] then
            board:attach(name .. item, Icon:new(item, iconfor(name .. item))).onopen = onopen
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
    local ext = string.lower(string.sub(filename, 1 - string.find(string.reverse(filename), "%.")))
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
  local sw, sh = scrn:size()
  local win = scrn:attachwindow(filename, Window:new(filename, winx, winy, sw / 2, sh / 2))
  win.resizable = true
  win.onclose = function()
    scrn:destroychild(filename)
  end
  win:attach("items", Icon.Board:new())
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
    local ext = string.lower(string.sub(filename, 1 - string.find(string.reverse(filename), "%.")))
    print(ext)
    if fs.isfile(_DRIVE .. "icons/" .. ext .. ".gif") then
      return _DRIVE .. "icons/" .. ext .. ".gif"
    end
  end
  return _DRIVE .. "icons/file.gif"
end
