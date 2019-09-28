local Screen, Window, Icon = require("screen"), require("window"), require("icon")
local scrn, desktop, dirwins
local nextrefresh = 0

function _init()
  scrn = Screen:new("Homegirl Workshop", 11, 2)
  scrn:palette(0, 8, 8, 8)
  scrn:palette(1, 0, 0, 0)
  scrn:palette(2, 15, 15, 15)
  scrn:palette(3, 7, 11, 15)
  scrn:autocolor()

  desktop = scrn:attach("desktop", Icon.Board:new())
  dirwins = {}
  scrn:step(0)
end

function _step(t)
  if t > nextrefresh then
    local drives = fs.drives()
    table.sort(drives)
    for i, drive in ipairs(drives) do
      drives[drive .. ":"] = true
      if not desktop.children[drive .. ":"] then
        desktop:attach(drive .. ":", Icon:new(drive .. ":", _DRIVE .. "icons/drive.gif"))
      end
    end
    for name, child in pairs(desktop.children) do
      if not drives[name] then
        print("destroying " .. name)
        desktop:destroychild(name)
      end
    end
    nextrefresh = t + 1024
  end
  scrn:step(t)

  view.active(scrn.rootvp)
  if input.hotkey() == "\x1b" then
    sys.exit()
  end
end
