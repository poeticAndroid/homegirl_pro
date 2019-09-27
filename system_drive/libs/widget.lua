local Object = require("object")

local Widget = Object:extend()
do
  Widget.darkcolor = 1
  Widget.lightcolor = 2
  Widget.fgcolor = 3
  Widget.bgcolor = 0
  Widget.fgtextcolor = 1
  Widget.bgtextcolor = 1
  Widget.parentvp = false
  Widget.font = text.loadfont("Victoria.8b")

  function Widget:_new(label)
    self.label = label
  end

  function Widget:attachto(vp, screen)
    if self.parentvp ~= vp then
      local l, t, w, h = 0, 0, 8, 8
      if self.container then
        l, t = view.position(self.container)
        w, h = view.size(self.container)
        view.remove(self.container)
      end
      self.parentvp = vp
      if screen then
        Widget.screen = screen
      end
      self.screen = Widget.screen
      self.container = view.new(self.parentvp, l, t, w, h)
    end
  end

  function Widget:destroy()
    if self.children then
      for name, child in pairs(self.children) do
        child:destroy()
      end
    end
    self.children = nil
    view.remove(self.container)
    self.container = nil
    self.parentvp = nil
    self.screen = nil
  end
  function Widget:destroychild(name)
    local child = self.children[name]
    child:destroy()
    table.remove(self.children, name)
  end

  function Widget:position(left, top)
    return view.position(self.container, left, top)
  end
  function Widget:size(width, height)
    return view.size(self.container, width, height)
  end

  function Widget:step(t)
    if self.children then
      for name, child in pairs(self.children) do
        child:step(t)
      end
    end
  end

  function Widget:outset(x, y, w, h)
    gfx.fgcolor(self.lightcolor)
    gfx.bar(x, y, w, 1)
    gfx.bar(x, y, 1, h)
    gfx.fgcolor(self.darkcolor)
    gfx.bar(x + w - 1, y + 1, 1, h - 1)
    gfx.bar(x, y + h - 1, w, 1)
  end
  function Widget:inset(x, y, w, h)
    gfx.fgcolor(self.darkcolor)
    gfx.bar(x, y, w, 1)
    gfx.bar(x, y, 1, h)
    gfx.fgcolor(self.lightcolor)
    gfx.bar(x + w - 1, y + 1, 1, h - 1)
    gfx.bar(x, y + h - 1, w, 1)
  end

  function Widget:gotclicked(vp)
    local clicked = false
    local prevvp = view.active()
    view.active(vp)
    local mx, my, mb = input.mouse()
    if view.attribute(vp, "pressed") == "true" and mb == 0 then
      clicked = true
    end
    if mb == 0 then
      view.attribute(vp, "pressed", "false")
    else
      local w, h = view.size(vp)
      if mx >= 0 and my >= 0 and mx < w and my < h then
        view.attribute(vp, "pressed", "true")
      else
        view.attribute(vp, "pressed", "false")
      end
    end
    view.active(prevvp)
    return clicked
  end
end
return Widget
