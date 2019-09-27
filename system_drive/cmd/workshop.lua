local Screen, Window = require("Screen"), require("Window")
local scrn, win

local icons = {}

function _init()
  scrn = Screen:new("Homegirl Workshop", 11, 2)
  scrn:palette(0, 8, 8, 8)
  scrn:palette(1, 0, 0, 0)
  scrn:palette(2, 15, 15, 15)
  scrn:palette(3, 7, 11, 15)
  scrn:autocolor()
  local w, h = scrn:size()
  for y = 0, h do
    for x = 0, w do
      gfx.pixel(x, y, (x + y) % 2)
    end
  end
  win = scrn:attachwindow(nil, Window:new("Work in progress", 32, 32, 350, 45))
  win.resizable = true
  win.onclose = function() end
  win.onhide = function() end
  
  for i,name in pairs(fs.list(_DRIVE.."icons/")) do
    table.insert(icons, image.load(_DRIVE.."icons/"..name)[1])
  end
end

function _step(t)
  scrn:step(t)
  view.active(win.mainvp)
  text.draw("Homegirl Workshop is under development!", scrn:font(), 4,4)
  text.draw("Thank you for your patience.. :)", scrn:font(), 4,12)
  local x,y = 8,24
  for i,icon in pairs(icons) do
    image.draw(icon, x,y, 0,0, image.size(icon))
    x = x + 80
  end
  view.active(scrn.rootvp)
  if input.hotkey() == "\x1b" then
    sys.exit()
  end
end
