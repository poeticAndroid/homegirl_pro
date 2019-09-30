local Widget = require("widget")

local Scrollbox = Widget:extend()
do
  function Scrollbox:_new()
    self.children = {}
    self.barsize = 8
  end
  function Scrollbox:attachto(...)
    Widget.attachto(self, ...)
    -- view.remove(self.container)
    -- self.container = self.parentvp
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
    local bw, bh, bp, bs
    local vw, vh = view.size(self.parentvp)
    vw, vh = self:size(vw - self.barsize, vh - self.barsize)
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
    self:outset(bp * (bw - 2) + 1, 1, bs * (bw - 2), bh - 2)
    self:inset(0, 0, bw, bh)

    view.active(self._vscrollbar)
    view.zindex(self._vscrollbar, -1)
    view.position(self._vscrollbar, vw, 0)
    bw, bh = view.size(self._vscrollbar, self.barsize, vh)
    bs = math.min(1, bh / ch)
    bp = -ct / ch
    gfx.cls()
    self:outset(1, bp * (bh - 2) + 1, bw - 2, bs * (bh - 2))
    self:inset(0, 0, bw, bh)

    view.active(prevvp)
  end

  function Scrollbox:destroy()
    if self.children then
      for name, child in pairs(self.children) do
        child:destroy()
      end
    end
    self.children = nil
    self.container = nil
    self.parentvp = nil
    self.screen = nil
  end
end

return {
  Scrollbox = Scrollbox
}
