local defaultfont = text.loadfont("Victoria.8b")

local Window = {}
do
  Window.__index = Window

  function Window:new(parent, title, left,top, width,height)
    local self = setmetatable({}, Window)
    self.rootvp = view.new(parent, left,top, width,height)
    self.mainvp = view.new(self.rootvp, 0, 8, 8, 8)
    self._resbtn= view.new(self.rootvp, 0, 8, 8, 8)
    view.active(self.mainvp)
    self:colors(1, 0)
    self:font(defaultfont)
    self:title(title)
    return self
  end
  
  function Window:colors(bg, fg)
    if bg then
      self._bgcolor = bg
      self._fgcolor = fg
      self:title(self._title)
    end
    return self._bgcolor, self._fgcolor
  end

  function Window:redraw()
    local prevvp = view.active()
    view.active(self.rootvp)
    local sw, sh = view.size(self.rootvp)
    local tw, th = text.draw(self._title, self._font, 0, 0)
    self._titleheight = th
    view.position(self.mainvp, 1, th + 2)
    view.size(self.mainvp, sw-2, sh - th - 3)
    view.position(self._resbtn, sw-8,sh-8)
    self:title(self._title)
    view.active(self._resbtn)
    gfx.bgcolor(self._bgcolor)
    gfx.cls()
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
      local prevvp = view.active()
      view.active(self.rootvp)
      gfx.bgcolor(self._bgcolor)
      gfx.fgcolor(self._fgcolor)
      gfx.cls()
      local vw, vh = view.size(self.rootvp)
      local tw, th = text.draw(self._title, self._font, 1, 1)
      view.active(prevvp)
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
        self._moving=true
        self._movingx=x
        self._movingy=y
        view.zindex(self.rootvp, -1)
      end
    end
    if btn == 1 then
      if self._moving then
        local left,top = self:position()
        self:position(left +x -self._movingx, top + y -self._movingy)
      end
    elseif view.focused(self.rootvp) then
      self._moving=false
      self:title(self._title)
      view.focused(self.mainvp, true)
    end
    self._lastmbtn = btn
    view.active(self._resbtn)
    local _x,_y,btn = input.mouse()
    if btn == 1 then
      self:size(x+4,y+4)
      self:redraw()
    end
    view.active(prevvp)
  end

  function Window:position(left,top)
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
    self:colors(bg, fg)
    view.active(prevvp)
  end

end
return Window
