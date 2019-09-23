local Screen, Window = require("Screen"), require("Window")
local scrn, win

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
  win = scrn:attachwindow(nil, Window:new("some folder", 32, 32, 320, 90))
  win.resizable = true
  win2 = win:attach(nil, Window:new("nest me!", 32, 32, 320, 90))
  win2.resizable = true
end

function _step(t)
  scrn:step(t)
  view.active(scrn.rootvp)
  if input.hotkey() == "\x1b" then
    sys.exit()
  end
end
