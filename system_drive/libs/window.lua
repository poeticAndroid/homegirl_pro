Class = require("class")

local defaultfont = text.loadfont("Victoria.8b")

local Window = {}
do
  function Window:new(parent, title, left, top, width, height)
    self.rootvp = view.new(parent, left, top, width, height)
    self.mainvp = view.new(self.rootvp, 0, 8, 8, 8)
    self._resbtn = view.new(self.rootvp, 0, 8, 8, 8)
    view.active(self.mainvp)
    self:font(defaultfont)
    self:colors(1, 2, 3, 0)
    self:title(title)
  end
  Window = Class:new(nil, Window.new)

  function Window:colors(shine, shadow, focus, blur)
    if blur then
      self._shinec = shine
      self._shadowc = shadow
      self._focusc = focus
      self._blurc = blur
      self:redraw()
    end
  end

  function Window:redraw()
    local prevvp = view.active()
    local focused = view.focused(self.rootvp)
    view.active(self.rootvp)
    local sw, sh = view.size(self.rootvp)
    local tw, th = text.draw(self._title, self._font, 0, 0)
    self._titleheight = th
    view.position(self.mainvp, 3, th + 3)
    view.size(self.mainvp, sw - 6, sh - th - 6)
    view.position(self._resbtn, sw - 8, sh - 8)
    gfx.bgcolor(focused and self._focusc or self._blurc)
    gfx.cls()
    gfx.fgcolor(self._shadowc)
    text.draw(self._title, self._font, 2, 2)
    self:outset(0, 0, sw, sh)
    self:inset(2, th + 2, sw - 4, sh - th - 4)
    view.active(self._resbtn)
    gfx.bgcolor(focused and self._focusc or self._blurc)
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
      self._title = view.attribute(self.rootvp, "title", title)
      self:redraw()
    end
    return self._title
  end

  function Window:step()
    local prevvp = view.active()
    view.active(self.rootvp)
    local vw, vh = view.size(self.rootvp)
    local x, y, btn = input.mouse()
    if self._lastmbtn == 0 and btn == 1 then
      if y < self._titleheight then
        self._moving = true
        self._movingx = x
        self._movingy = y
        view.zindex(self.rootvp, -1)
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
    if self._focused ~= view.focused(self.rootvp) then
      self._focused = view.focused(self.rootvp)
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

  function Window:position(left, top)
    if top then
      view.position(self.rootvp, left, top)
    end
    return view.position(self.rootvp)
  end

  function Window:size(width, height)
    if height then
      view.size(self.rootvp, width, height)
    end
    return view.size(self.rootvp)
  end

  function Window:autocolor()
    local prevvp = view.active()
    view.active(self.rootvp)
    local r, g, b, bg, fg, bgv, fgv, v
    local colors = math.pow(2, self._colorbits)
    bgv = -1
    fgv = 60
    for c = 0, colors - 1 do
      r, g, b = gfx.palette(c)
      v = r + g + b
      if v > bgv then
        bgv = v
        bg = c
      end
      if v < fgv then
        fgv = v
        fg = c
      end
    end
    self:colors(bg, fg, 3, 0)
    view.active(prevvp)
  end

  function Window:outset(x, y, w, h)
    gfx.fgcolor(self._shinec)
    gfx.bar(x, y, w, 1)
    gfx.bar(x, y, 1, h)
    gfx.fgcolor(self._shadowc)
    gfx.bar(x + w - 1, y + 1, 1, h - 1)
    gfx.bar(x, y + h - 1, w, 1)
  end
  function Window:inset(x, y, w, h)
    gfx.fgcolor(self._shadowc)
    gfx.bar(x, y, w, 1)
    gfx.bar(x, y, 1, h)
    gfx.fgcolor(self._shinec)
    gfx.bar(x + w - 1, y + 1, 1, h - 1)
    gfx.bar(x, y + h - 1, w, 1)
  end
end
return Window
