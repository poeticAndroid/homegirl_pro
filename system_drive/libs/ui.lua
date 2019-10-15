local Widget = require("widget")

local Button = Widget:extend()
do
  function Button:_new(label)
    self.label = label
  end
  function Button:step(t)
    local prevvp = view.active()
    local redraw
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local mx, my, mb = input.mouse()
    if not self._pressed and mb == 1 then
      redraw = true
    end
    if self._pressed and mb == 0 then
      redraw = true
      if self.onclick then
        self:onclick()
      end
    end
    self._pressed = mb == 1
    if mx < 0 or my < 0 or mx >= vw or my >= vh then
      self._pressed = false
    end
    if redraw then
      self:redraw()
    end
    view.active(prevvp)
  end
  function Button:redraw()
    local prevvp = view.active()
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local tw, th = text.draw(self.label, self.font)
    if self._pressed then
      gfx.bgcolor(self.fgcolor)
      gfx.cls()
      gfx.fgcolor(self.fgtextcolor)
      text.draw(self.label, self.font, vw / 2 - tw / 2, vh / 2 - th / 2)
      self:inset(0, 0, vw, vh)
    else
      gfx.bgcolor(self.bgcolor)
      gfx.cls()
      gfx.fgcolor(self.bgtextcolor)
      text.draw(self.label, self.font, vw / 2 - tw / 2, vh / 2 - th / 2)
      self:outset(0, 0, vw, vh)
    end
    view.active(prevvp)
  end
end

local Scrollbox = Widget:extend()
do
  function Scrollbox:_new()
    self.children = {}
    self.barsize = 8
  end
  function Scrollbox:attachto(...)
    Widget.attachto(self, ...)
    self._hscrollbar = view.new(self.parentvp)
    self._vscrollbar = view.new(self.parentvp)
    self:redraw()
  end
  function Scrollbox:step(time)
    local prevvp = view.active()
    local mx, my, mb, bw, bh, bp
    for name, child in pairs(self.children) do
      child:step(time)
      self.child = child.container
    end
    if not self.child then
      view.active(prevvp)
      return
    end
    local cl, ct = view.position(self.child)
    local cw, ch = view.size(self.child)

    view.active(self._hscrollbar)
    bw, bh = view.size(self._hscrollbar)
    mx, my, mb = input.mouse()
    if mb == 1 then
      bp = cw / bw
      if not self._scrollx then
        self._scrollx = mx * bp + cl
      end
      view.position(self.child, math.min(math.max(-cw + bw, self._scrollx - mx * bp), 0), ct)
    else
      self._scrollx = nil
    end

    view.active(self._vscrollbar)
    bw, bh = view.size(self._vscrollbar)
    mx, my, mb = input.mouse()
    if mb == 1 then
      bp = ch / bh
      if not self._scrolly then
        self._scrolly = my * bp + ct
      end
      view.position(self.child, cl, math.min(math.max(-ch + bh, self._scrolly - my * bp), 0))
    else
      self._scrolly = nil
    end
    self:redraw()
    view.active(prevvp)
  end
  function Scrollbox:redraw()
    local prevvp = view.active()
    if not self._dither then
      view.active(self.container)
      view.size(self.container, 2, 2)
      self._dither = image.new(2, 2, 2)
      gfx.fgcolor(self.bgcolor)
      gfx.bar(0, 0, 2, 2)
      gfx.fgcolor(self.darkcolor)
      gfx.plot(0, 0)
      gfx.plot(1, 1)
      image.copy(self._dither, 0, 0, 0, 0, 2, 2)
    end
    local bw, bh, bp, bs
    local vw, vh = view.size(self.parentvp)
    vw, vh = view.size(self.container, vw - self.barsize, vh - self.barsize)
    if not self.child then
      return
    end
    local cl, ct = view.position(self.child)
    local cw, ch = view.size(self.child)

    view.active(self._hscrollbar)
    view.zindex(self._hscrollbar, -1)
    view.position(self._hscrollbar, 0, vh)
    bw, bh = view.size(self._hscrollbar, vw, self.barsize)
    bs = math.min(1, bw / cw)
    bp = -cl / cw
    gfx.cls()
    image.draw(self._dither, 0, 0, 0, 0, bw, bh)
    self:inset(0, 0, bw + 1, bh + 1)
    gfx.fgcolor(self.bgcolor)
    gfx.bar(bp * bw, 1, bs * bw, bh - 1)
    self:outset(bp * bw, 1, bs * bw, bh - 1)

    view.active(self._vscrollbar)
    view.zindex(self._vscrollbar, -1)
    view.position(self._vscrollbar, vw, 0)
    bw, bh = view.size(self._vscrollbar, self.barsize, vh)
    bs = math.min(1, bh / ch)
    bp = -ct / ch
    gfx.cls()
    image.draw(self._dither, 0, 0, 0, 0, bw, bh)
    self:inset(0, 0, bw + 1, bh + 1)
    gfx.fgcolor(self.bgcolor)
    gfx.bar(1, bp * bh, bw - 1, bs * bh)
    self:outset(1, bp * bh, bw - 1, bs * bh)

    view.active(prevvp)
  end
end

return {
  Button = Button,
  Scrollbox = Scrollbox
}
