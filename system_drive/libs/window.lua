local Widget = require("Widget")

local defaultfont = text.loadfont("Victoria.8b")

local Window = Widget:extend()
do
  function Window:_new(title, left, top, width, height, parent)
    self.children = {}
    self:attachto(parent, parent)
    self:position(left, top)
    self:size(width, height)
    self:font(defaultfont)
    self:title(title)
  end

  function Window:attachto(vp, screen)
    if self.parentvp ~= vp then
      Widget.attachto(self, vp, screen)
      self.mainvp = view.new(self.container)
      self._closebtn = view.new(self.container)
      self._titlevp = view.new(self.container)
      self._hidebtn = view.new(self.container)
      self._resbtn = view.new(self.container)
      view.active(self.mainvp)
    end
  end
  function Window:attach(name, child)
    if name then
      self.children[name] = child
    else
      table.insert(self.children, child)
    end
    child:attachto(self.mainvp, self.container)
    return child
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
    local tw, th = text.draw(self._title, self._font, 0, 0)
    local btnw, btnh = math.ceil((th + 2) * 1.5), th + 2
    view.position(self.mainvp, 3, btnh)
    view.size(self.mainvp, sw - 6, sh - btnh - 3)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    self:outset(0, 0, sw, sh)
    self:inset(2, 2, sw - 4, sh - 4)

    view.active(self._closebtn)
    mx, my, mbtn = input.mouse()
    view.size(self._closebtn, btnw, btnh)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.bar(4, 3, btnw - 8, btnh - 6)
    gfx.fgcolor(focused and self.lightcolor or self.bgcolor)
    gfx.bar(5, 4, btnw - 10, btnh - 8)
    if mbtn == 1 then
      self:inset(0, 0, btnw, btnh)
    else
      self:outset(0, 0, btnw, btnh)
    end

    view.active(self._titlevp)
    view.position(self._titlevp, btnw, 0)
    view.size(self._titlevp, sw - btnw * 2, btnh)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.fgcolor(self.textcolor)
    text.draw(self._title, self._font, math.max(2, (sw - btnw * 2) / 2 - tw / 2), 1)
    self:outset(0, 0, sw - btnw * 2, btnh)

    view.active(self._hidebtn)
    mx, my, mbtn = input.mouse()
    view.position(self._hidebtn, sw - btnw, 0)
    view.size(self._hidebtn, btnw, btnh)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.bar(3, 2, btnw - 6, btnh - 4)
    gfx.fgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.bar(4, 3, btnw - 8, btnh - 6)
    gfx.fgcolor(self.darkcolor)
    gfx.bar(3, 2, btnw / 2 - 2, btnh / 2 - 1)
    gfx.fgcolor(focused and self.lightcolor or self.bgcolor)
    gfx.bar(4, 3, btnw / 2 - 4, btnh / 2 - 3)
    if mbtn == 1 then
      self:inset(0, 0, btnw, btnh)
    else
      self:outset(0, 0, btnw, btnh)
    end

    view.active(self._resbtn)
    mx, my, mbtn = input.mouse()
    view.position(self._resbtn, sw - 8, sh - 8)
    view.size(self._resbtn, 8, 8)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    self:outset(0, 0, 10, 10)
    self:outset(-2, -2, 10, 10)
    gfx.pixel(0, 6, gfx.pixel(1, 6))
    gfx.pixel(6, 0, gfx.pixel(6, 1))
    view.active(prevvp)
  end

  function Window:font(font)
    if font then
      self._font = font
      self:redraw()
    end
    return self._font
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
    local bw, bh = view.size(self._closebtn)
    if w < bw * 2 then
      w = bw * 2
    end
    if h < bh * 2 then
      h = bh * 2
    end
    return Widget.size(self, w, h)
  end

  function Window:step()
    local prevvp = view.active()
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local mx, my, mbtn, _x, _y = input.mouse()
    if self._lastmbtn == 0 and mbtn == 1 then
      view.zindex(self.container, -1)
    end
    if mbtn == 1 then
      if self._moving then
        local left, top = self:position()
        self:position(left + mx - self._movingx, top + my - self._movingy)
      end
    else
      self._moving = false
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
      self:size(mx + 4, my + 4)
      self:redraw()
    else
      self:position()
    end

    view.active(self.container)
    _x, _y, mbtn = input.mouse()
    if self._focused ~= view.focused(self.container) or self._lastmbtn ~= mbtn then
      self._focused = view.focused(self.container)
      self._lastmbtn = mbtn
      self:redraw()
    end
    view.active(prevvp)
  end
end
return Window
