local Widget = require("widget")

local Label = Widget:extend()
do
  function Label:redraw()
    local prevvp = view.active()
    view.active(self.container)
    gfx.bgcolor(self.bgcolor)
    gfx.cls()
    gfx.fgcolor(self.bgtextcolor)
    text.draw(self.label, self.font, 0, 0)
    view.active(prevvp)
  end
end

local Button = Widget:extend()
do
  function Button:step(t)
    local prevvp = view.active()
    local redraw
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local mx, my, mb = input.mouse()
    if mx < 0 or my < 0 or mx >= vw or my >= vh then
      redraw = true
      self._pressed = false
      mb = 0
    end
    if not self._pressed and mb == 1 then
      redraw = true
      if self.onpress then
        self:onpress()
      end
    end
    if self._pressed and mb == 0 then
      redraw = true
      if self.onclick then
        self:onclick()
      end
    end
    self._pressed = mb == 1
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

local TextInput = Widget:extend()
do
  function TextInput:_new(content)
    self.content = content or ""
    self.cursor = #(self.content)
    self.selectedbytes = 0
    self.scrollx, self.scrolly = 0, 0
    self.border = 2
  end

  function TextInput:step(t)
    local prevvp = view.active()
    view.active(self.container)
    local mx, my, mb = input.mouse()
    local redraw = mb == 1 or self._selecting
    local drop = input.drop()
    if drop then
      input.selected(drop)
    end
    local txt = input.text()
    local pos, sel = input.cursor()
    if self.content ~= txt or self.cursor ~= pos or self.selectedbytes ~= sel then
      redraw = true
      self.content = txt
      self.cursor = pos
      self.selectedbytes = sel
    end
    if redraw then
      self:redraw()
    end
    view.active(prevvp)
  end

  function TextInput:setcontent(txt)
    local prevvp = view.active()
    local redraw
    view.active(self.container)
    if self.content ~= txt then
      redraw = true
      self.content = input.text(txt)
    end
    if redraw then
      self:redraw()
    end
    view.active(prevvp)
  end

  function TextInput:redraw()
    local prevvp = view.active()
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local mx, my, mb = input.mouse()
    gfx.bgcolor(self.bgcolor)
    gfx.cls()
    local margin = self.scrollx
    local x, y, tw, th = self.border - margin, self.border - self.scrolly, 8, 8
    local pos, sel = self.cursor, self.selectedbytes
    local lines = self:_getlines(self.content)
    for i, line in ipairs(lines) do
      gfx.fgcolor(self.bgtextcolor)
      tw, th = text.draw(string.sub(line, 1, math.max(0, pos)), self.font, x, y)
      x = x + tw
      if pos >= 0 and pos <= #line and (y < self.border or x < self.border) then
        self.cursor = self.cursor + 1
        self.scrollx = math.min(self.scrollx, self.scrollx + x - self.border)
        self.scrolly = math.min(self.scrolly, self.scrolly + y - self.border)
      end
      tw, th = text.draw(string.sub(line, 1 + math.max(0, pos), math.max(0, pos + sel)), self.font, x, y)
      gfx.fgcolor(self.fgcolor)
      if sel == 0 and pos >= 0 and pos <= #line then
        gfx.bar(x - 1, y, 2, th)
      elseif pos + sel > #line and pos <= #line then
        gfx.bar(x, y, vw + self.scrollx, th)
      else
        gfx.bar(x, y, tw, th)
      end
      gfx.fgcolor(self.fgtextcolor)
      tw, th = text.draw(string.sub(line, 1 + math.max(0, pos), math.max(0, pos + sel)), self.font, x, y)
      x = x + tw
      if pos + sel >= 0 and pos + sel <= #line and (y + th > vh or x + 8 > vw) then
        self.cursor = self.cursor - 1
        self.scrollx = math.max(self.scrollx, self.scrollx + x - vw + 8)
        self.scrolly = math.max(self.scrolly, self.scrolly + y - vh + th + self.border)
      end
      gfx.fgcolor(self.bgtextcolor)
      tw, th = text.draw(string.sub(line, 1 + math.max(0, pos + sel)), self.font, x, y)

      if mb == 1 and my >= y then
        local ls = self.cursor - pos
        local p = #line + 1
        tw = vw + self.scrollx
        while mx < tw + self.border - 2 - self.scrollx and p > 0 do
          p = p - 1
          tw, th = text.draw(string.sub(line, 1, p), self.font, x, vh)
        end
        p = p + ls
        if self._selecting then
          if p > self._selecting then
            input.cursor(self._selecting, p - self._selecting)
          else
            input.cursor(p, self._selecting - p)
          end
        else
          input.cursor(p)
        end
      end

      pos = pos - #line - 1
      y = y + th
      x = self.border - margin
    end
    input.linesperpage(math.floor((vh - self.border * 2) / th))
    if not self._selecting and mb == 1 then
      self._selecting = input.cursor()
    end
    if mb == 0 then
      self._selecting = nil
    end
    if self.border > 0 then
      self:outset(0, 0, vw, vh)
    end
    local b = math.min(1, self.border - 1)
    self:inset(b, b, vw - b * 2, vh - b * 2)
    view.active(prevvp)
  end

  function TextInput:_getlines(txt)
    local lines = {}
    local s, e = 1, string.find(txt, "\n")
    while e do
      table.insert(lines, string.sub(txt, s, e - 1))
      s = e + 1
      e = string.find(txt, "\n", s)
    end
    table.insert(lines, string.sub(txt, s))
    return lines
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
  Label = Label,
  Button = Button,
  TextInput = TextInput,
  Scrollbox = Scrollbox
}
