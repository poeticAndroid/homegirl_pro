local Widget = require("widget")

local Window = Widget:extend()
do
  function Window:_new(title, left, top, width, height, parent)
    self.children = {}
    self:attachto(nil, parent, parent)
    self:size(width, height)
    self:position(left, top)
    self:title(title)
  end

  function Window:attachto(...)
    Widget.attachto(self, ...)
    self.mainvp = view.new(self.container)
    self._closebtn = view.new(self.container)
    self._titlevp = view.new(self.container)
    self._hidebtn = view.new(self.container)
    self._resbtn = view.new(self.container, 8, 8, 8, 8)
    self:title(self:title())
    self:icon("sys:icons/lua.gif")
    view.active(self.mainvp)
    self:redraw()
    if view.attribute(self.parentvp, "hide-enabled") == "true" then
      self.onhide = function(self)
        view.visible(self.container, false)
      end
    end
  end

  function Window:redraw()
    if not self.container then
      return
    end
    local prevvp = view.active()
    view.active(self.container)
    local focused = view.focused(self.container)
    local mx, my, mbtn = input.mouse()
    local sw, sh = view.size(self.container)
    local tw, th = text.draw(self._title, self.font, 0, 0)
    local btnw, btnh = math.ceil((th + 2) * 1.5), th + 2
    view.position(self.mainvp, 3, btnh)
    view.size(self.mainvp, sw - 6, sh - btnh - 3)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    self:outset(0, 0, sw, sh)
    self:inset(2, 2, sw - 4, sh - 4)

    view.active(self._closebtn)
    view.size(self._closebtn, btnw, btnh)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.fgcolor(self.darkcolor)
    gfx.bar(4, 3, btnw - 8, btnh - 6)
    gfx.fgcolor(focused and self.lightcolor or self.bgcolor)
    gfx.bar(5, 4, btnw - 10, btnh - 8)
    if view.attribute(self._closebtn, "pressed") == "true" then
      self:inset(0, 0, btnw, btnh)
    else
      self:outset(0, 0, btnw, btnh)
    end
    view.visible(self._closebtn, self.onclose and true or false)

    view.active(self._titlevp)
    local btns = 0
    if self.onclose then
      btns = btns + 1
    end
    view.position(self._titlevp, btnw * btns, 0)
    if self.onhide then
      btns = btns + 1
    end
    local w, h = view.size(self._titlevp, sw - btnw * btns, btnh)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.fgcolor(focused and self.fgtextcolor or self.bgtextcolor)
    text.draw(self._title, self.font, math.min(w - tw, w / 2 - tw / 2), 1)
    self:outset(0, 0, w, h)
    if not self.onclose then
      gfx.pixel(0, h - 1, gfx.pixel(0, h - 2))
      gfx.pixel(1, h - 1, gfx.pixel(1, h - 2))
    end
    if not self.onhide then
      gfx.pixel(w - 2, h - 1, gfx.pixel(w - 2, h - 2))
    end

    view.active(self._hidebtn)
    view.position(self._hidebtn, sw - btnw, 0)
    view.size(self._hidebtn, btnw, btnh)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.fgcolor(self.darkcolor)
    gfx.bar(3, 2, btnw - 6, btnh - 4)
    gfx.fgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.bar(4, 3, btnw - 8, btnh - 6)
    gfx.fgcolor(self.darkcolor)
    gfx.bar(3, 2, btnw / 2 - 2, btnh / 2 - 1)
    gfx.fgcolor(focused and self.lightcolor or self.bgcolor)
    gfx.bar(4, 3, btnw / 2 - 4, btnh / 2 - 3)
    if view.attribute(self._hidebtn, "pressed") == "true" then
      self:inset(0, 0, btnw, btnh)
    else
      self:outset(0, 0, btnw, btnh)
    end
    view.visible(self._hidebtn, self.onhide and true or false)

    view.active(self._resbtn)
    local w, h = view.size(self._resbtn)
    view.position(self._resbtn, sw - w, sh - h)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    self:outset(0, 0, w + 1, h + 1)
    self:outset(-1, -1, w + 1, h + 1)
    gfx.pixel(0, h - 2, gfx.pixel(1, h - 2))
    gfx.pixel(w - 2, 0, gfx.pixel(w - 2, 1))
    view.visible(self._resbtn, self.resizable and true or false)
    view.active(prevvp)
  end

  function Window:title(title)
    if title then
      if self.container then
        self._title = view.attribute(self.container, "title", title)
      end
      self:redraw()
    end
    return self._title
  end
  function Window:icon(icon)
    if icon then
      if self.container then
        self._icon = view.attribute(self.container, "icon", icon)
      end
    end
    return self._icon
  end

  function Window:position(l, t)
    if not t then
      l, t = view.position(self.container)
    end
    local sw, sh = view.size(self.parentvp)
    local ww, wh = view.size(self.container)
    local bw, bh = view.size(self._closebtn)
    local minl = -ww + bw * 2
    local maxl = sw - bw * 2
    local mint = 0
    local maxt = sh - bh
    local thres = 16
    if l >= 0 and t >= 0 and l <= sw - ww and t <= sh - wh then
      self._snapped = false
    end
    if l < -thres or t < -thres or l > sw - ww + thres or t > sh - wh + thres then
      self._snapped = true
    end
    if not self._snapped then
      minl, mint = 0, 0
      maxl, maxt = sw - ww, sh - wh
    end
    if wh > sh then
      maxl = sw - ww
      maxt = sh - wh
    end
    if l < minl then
      l = minl
    end
    if t < mint then
      t = mint
    end
    if l > maxl then
      l = maxl
    end
    if t > maxt then
      t = maxt
    end
    return Widget.position(self, l, t)
  end
  function Window:size(w, h)
    if not h then
      w, h = view.size(self.container)
    end
    local wl, wt = view.position(self.container)
    local sw, sh = view.size(self.parentvp)
    local bw, bh = view.size(self._closebtn)
    local minw, minh = bw * 2, bh * 2
    local maxw, maxh = 640, 480
    if not self._snapped then
      maxw, maxh = sw - wl, sh - wt
    end
    if w < minw then
      w = minw
    end
    if h < minh then
      h = minh
    end
    if w > maxw then
      w = maxw
    end
    if h > maxh then
      h = maxh
    end
    return Widget.size(self, w, h)
  end

  function Window:step(time)
    local prevvp = view.active()
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local mx, my, mbtn, _x, _y = input.mouse()
    if self._lastmbtn == 0 and mbtn == 1 then
      view.zindex(self.container, -1)
    end

    if self.onclose and self:gotclicked(self._closebtn) then
      self:redraw()
      view.active(prevvp)
      return self:onclose()
    end

    if self.onhide and self:gotclicked(self._hidebtn) then
      self:redraw()
      view.active(prevvp)
      return self:onhide()
    end

    view.active(self._titlevp)
    _x, _y, mbtn = input.mouse()
    if mbtn == 1 and not self._moving then
      self._moving = true
      self._movingx = mx
      self._movingy = my
    end

    view.active(self._resbtn)
    _x, _y, mbtn = input.mouse()
    if mbtn == 1 then
      vw, vh = view.size(self._resbtn)
      self:size(mx + vw / 2, my + vh / 2)
      self:redraw()
    else
      self:position()
    end

    view.active(self.container)
    _x, _y, mbtn = input.mouse()
    if mbtn == 1 then
      if self._moving then
        local left, top = self:position()
        self:position(left + mx - self._movingx, top + my - self._movingy)
      end
    else
      self._moving = false
      if view.focused(self.container) then
        view.focused(self.mainvp, true)
      end
    end
    if self._focused ~= view.focused(self.container) or mbtn ~= 0 then
      self._focused = view.focused(self.container)
      self._lastmbtn = mbtn
      self:redraw()
    end
    for name, child in pairs(self.children) do
      child:step(time)
    end
    view.active(prevvp)
  end
end
return Window
