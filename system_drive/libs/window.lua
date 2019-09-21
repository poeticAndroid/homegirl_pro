local Widget = require("Widget")

local defaultfont = text.loadfont("Victoria.8b")

local Window = Widget:extend()
do
  function Window:_new(parent, title, left, top, width, height)
    self:attachto(parent, parent)
    self:position(left, top)
    self:size(width, height)
    self:font(defaultfont)
    self:title(title)
  end

  function Window:attachto(vp, screen)
    Widget.attachto(self, vp, screen)
    self.mainvp = view.new(self.container, 0, 8, 8, 8)
    self._resbtn = view.new(self.container, 0, 8, 8, 8)
    view.active(self.mainvp)
  end

  function Window:redraw()
    if not self.container then
      return
    end
    local prevvp = view.active()
    local focused = view.focused(self.container)
    view.active(self.container)
    local sw, sh = view.size(self.container)
    local tw, th = text.draw(self._title, self._font, 0, 0)
    self._titleheight = th
    view.position(self.mainvp, 3, th + 3)
    view.size(self.mainvp, sw - 6, sh - th - 6)
    view.position(self._resbtn, sw - 8, sh - 8)
    gfx.bgcolor(focused and self.fgcolor or self.bgcolor)
    gfx.cls()
    gfx.fgcolor(self.textcolor)
    text.draw(self._title, self._font, 2, 2)
    self:outset(0, 0, sw, sh)
    self:inset(2, th + 2, sw - 4, sh - th - 4)
    view.active(self._resbtn)
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

  function Window:step()
    local prevvp = view.active()
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local x, y, btn = input.mouse()
    if self._lastmbtn == 0 and btn == 1 then
      if y < self._titleheight then
        self._moving = true
        self._movingx = x
        self._movingy = y
        view.zindex(self.container, -1)
      end
    end
    if btn == 1 then
      if self._moving then
        local left, top = self:position()
        self:position(left + x - self._movingx, top + y - self._movingy)
      end
    else
      self._moving = false
    end
    if self._focused ~= view.focused(self.container) then
      self._focused = view.focused(self.container)
      self:redraw()
    end
    self._lastmbtn = btn
    view.active(self._resbtn)
    local _x, _y, btn = input.mouse()
    if btn == 1 then
      self:size(x + 4, y + 4)
      self:redraw()
    end
    view.active(prevvp)
  end
end
return Window
