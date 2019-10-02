local Screen, Icon, path = require("screen"), require("icon"), require("path")
local scrn, desktop

function _init()
  scrn = Screen:new("Homegirl Workshop", 11, 2)
  scrn:palette(0, 10, 11, 12)
  scrn:palette(1, 0, 0, 0)
  scrn:palette(2, 15, 15, 15)
  scrn:palette(3, 5, 10, 15)
  scrn:colors(2, 1)

  desktop = scrn:attach("desktop", Icon.Board:new())
  desktop.backgroundimage = image.load(_DRIVE .. "stuff/homegirl_wallpaper.gif")[1]
  sys.stepinterval(-1)
end

function _step(t)
  view.active(scrn.rootvp)
  scrn:step(t)
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
  sys.stepinterval(sys.stepinterval() * -1)
end

function onopen(icon)
  local filename = icon.drop
  if fs.isdir(filename) then
    sys.exec(_DRIVE .. "cmd/open.lua", {filename})
  end
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
