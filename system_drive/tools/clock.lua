local Window = require("window")
local win
local _sec, _ms = 0, 0

function _init()
  win = Window:new("Clock", 456, 1, 160, 90)
  -- win:icon(_DIR .. _FILE .. ".gif")
  win.resizable = true
  win.onclose = function()
    sys.exit()
  end
  sys.stepinterval(64)
end

function _step(t)
  win:step(t)
  local h, m, s, ms = sys.time()
  if _sec ~= s then
    _ms = t
  else
    return
  end
  _sec = s
  ms = t - _ms
  view.active(win.mainvp)
  win:title(string.format("%d:%02d:%02d", h, m, s))
  local ww, wh = view.size(win.mainvp)
  ww = ww - 1
  wh = wh - 1
  local _x, _y, x, y, a = ww / 2, wh / 2
  -- backplate
  gfx.fgcolor(win.lightcolor)
  for a = 0, math.pi * 2, math.pi / 30 do
    x = ww / 2 + math.sin(a) * ww / 2
    y = wh / 2 - math.cos(a) * wh / 2
    gfx.tri(ww / 2, wh / 2, _x, _y, x, y)
    _x, _y = x, y
  end
  -- frame
  gfx.fgcolor(win.darkcolor)
  for a = 0, math.pi * 2, math.pi / 30 do
    x = ww / 2 + math.sin(a) * ww / 2
    y = wh / 2 - math.cos(a) * wh / 2
    gfx.line(_x, _y, x, y)
    _x, _y = x, y
  end
  -- min/sec marks
  for a = 0, math.pi * 2, math.pi / 30 do
    x = 0 + math.sin(a) * ww / 2
    y = 0 - math.cos(a) * wh / 2
    gfx.line(ww / 2 + x * .95, wh / 2 + y * .95, ww / 2 + x * .9, wh / 2 + y * .9)
  end
  -- hour marks
  for a = 0, math.pi * 2, math.pi / 6 do
    _x = 0 + math.sin(a - math.pi / 60) * ww / 2
    _y = 0 - math.cos(a - math.pi / 60) * wh / 2
    x = 0 + math.sin(a + math.pi / 60) * ww / 2
    y = 0 - math.cos(a + math.pi / 60) * wh / 2
    gfx.tri(
      ww / 2 + (_x + x) / 2 * .85,
      wh / 2 + (_y + y) / 2 * .85,
      ww / 2 + _x * .9,
      wh / 2 + _y * .9,
      ww / 2 + x * .90,
      wh / 2 + y * .90
    )
    gfx.tri(
      ww / 2 + (_x + x) / 2 * .95,
      wh / 2 + (_y + y) / 2 * .95,
      ww / 2 + _x * .9,
      wh / 2 + _y * .9,
      ww / 2 + x * .90,
      wh / 2 + y * .90
    )
  end
  -- hands
  a = math.pi * ((h + m / 60) / 6)
  gfx.tri(
    ww / 2,
    wh / 2,
    ww / 2 + math.sin(a) * ww / 2 * .65,
    wh / 2 - math.cos(a) * wh / 2 * .65,
    ww / 2 + math.sin(a - math.pi / 60) * ww / 2 * .5,
    wh / 2 - math.cos(a - math.pi / 60) * wh / 2 * .5
  )
  gfx.tri(
    ww / 2,
    wh / 2,
    ww / 2 + math.sin(a) * ww / 2 * .65,
    wh / 2 - math.cos(a) * wh / 2 * .65,
    ww / 2 + math.sin(a + math.pi / 60) * ww / 2 * .5,
    wh / 2 - math.cos(a + math.pi / 60) * wh / 2 * .5
  )
  a = math.pi * ((m + s / 60) / 30)
  gfx.tri(
    ww / 2,
    wh / 2,
    ww / 2 + math.sin(a) * ww / 2 * .85,
    wh / 2 - math.cos(a) * wh / 2 * .85,
    ww / 2 + math.sin(a - math.pi / 60) * ww / 2 * .75,
    wh / 2 - math.cos(a - math.pi / 60) * wh / 2 * .75
  )
  gfx.tri(
    ww / 2,
    wh / 2,
    ww / 2 + math.sin(a) * ww / 2 * .85,
    wh / 2 - math.cos(a) * wh / 2 * .85,
    ww / 2 + math.sin(a + math.pi / 60) * ww / 2 * .75,
    wh / 2 - math.cos(a + math.pi / 60) * wh / 2 * .75
  )
  a = math.pi * ((s + ms / 1000) / 30)
  gfx.fgcolor(win.fgcolor)
  gfx.line(ww / 2, wh / 2, ww / 2 + math.sin(a) * ww / 2 * .85, wh / 2 - math.cos(a) * wh / 2 * .85)
end
