local Widget = require("widget")

local Icon = Widget:extend()
do
  function Icon:_new(label, iconfile)
    self.label = label
    self.icon = image.load(iconfile)
    if not self.icon then
      self.icon = image.load(_DRIVE .. "icons/file.gif")
    end
    if not self.icon[2] then
      self.icon = image.load(_DRIVE .. "icons/file.gif")
    end
  end

  function Icon:attachto(...)
    Widget.attachto(self, ...)
    self:redraw()
  end

  function Icon:redraw()
    local prevvp = view.active()
    view.active(self.container)
    local vw, vh = view.size(self.container)
    local iw, ih = image.size(self.icon[1])
    local tw, th = text.draw(self.label, self.font)
    view.size(self.container, math.max(iw, tw), ih + th + 1)
    vw, vh = view.size(self.container)
    gfx.cls()
    gfx.fgcolor(self.fgtextcolor)
    image.draw(self.icon[self.selected and 2 or 1], vw / 2 - iw / 2, 0, 0, 0, iw, ih)
    text.draw(self.label, self.font, vw / 2 - tw / 2, ih + 1)
    view.active(prevvp)
  end

  function Icon:step(time)
    local prevvp = view.active()
    view.active(self.container)
    local mx, my, mb = input.mouse()
    if mb > 0 then
      if self.selected and self._dbltime > time then
        if self.onopen then
          self:onopen()
        end
      end
      self._dbltime = 0
      self:select()
    elseif self._dbltime == 0 then
      self._dbltime = time + 512
    end
    view.active(prevvp)
  end

  function Icon:select()
    self.selected = true
    self:redraw()
  end
  function Icon:deselect()
    self.selected = false
    self._dbltime = 0
    self:redraw()
  end

  function Icon:destroy()
    Widget.destroy(self)
    for i, icon in pairs(self.icon) do
      image.forget(icon)
    end
  end
end

local Board = Widget:extend()
do
  function Board:_new()
    self.children = {}
  end
  function Board:attach(name, child)
    name = name or child.label
    if self.children[name] then
      self:destroychild(name)
    end
    self.children[name] = child
    child:attachto(self.container, self.screen)
    self:tidychild(child)
    return child
  end
  function Board:attachto(...)
    Widget.attachto(self, ...)
    self:tidy()
  end

  function Board:tidy()
    self._col = 4
    self._row = 2
    self._nextcol = 0
    self._dirty = false
    self:size(view.size(self.parentvp))
    local names = {}
    for name, child in pairs(self.children) do
      table.insert(names, name)
    end
    table.sort(names)
    for i, name in pairs(names) do
      local child = self.children[name]
      self:tidychild(child)
    end
  end
  function Board:tidychild(child)
    local vw, vh = self:size()
    local cw, ch = child:size()
    if self._row + ch > vh then
      self._col = self._nextcol
      self._row = 2
    end
    child:position(self._col, self._row)
    self._nextcol = math.max(self._nextcol, self._col + cw + 4)
    self._row = self._row + ch + 2
  end

  function Board:step(time)
    local prevvp = view.active()
    view.active(self.container)
    local hotkey = input.hotkey()
    if hotkey == "a" then
      for name, child in pairs(self.children) do
        child:select()
      end
    elseif hotkey == "r" or not self._dirty then
      self:tidy()
    end
    gfx.cls()
    local vw, vh = self:size()
    for name, child in pairs(self.children) do
      child.drop = "" .. name
      local cx, cy = child:position()
      local cw, ch = child:size()
      if vw < cx + cw then
        vw = cx + cw
      end
      if vh < cy + ch then
        vh = cy + ch
      end
    end
    self:size(vw, vh)
    local mx, my, mb = input.mouse()
    local drop = input.drop()
    while drop do
      local icon
      if self.children[drop] then
        icon = self.children[drop]
      elseif self.ondrop then
        icon = self:ondrop(drop)
        if icon then
          icon = self:attach(drop, icon)
        end
      end
      if icon then
        local iw, ih = image.size(icon.icon[1])
        local cw, ch = icon:size()
        icon:position(mx - cw / 2, my - ih / 2)
        my = my + ch + 2
        if my > vh then
          my = ch / 2
          mx = mx + cw + 4
        end
        if mx > vw then
          mx = cw / 2
        end
      end
      drop = input.drop()
    end
    if self._draging and mb == 1 and (self._selx1 ~= mx or self._sely1 ~= my) then
      for name, child in pairs(self.children) do
        if child.selected then
          self._dirty = true
          input.drag(child.drop, child.icon[2])
        end
      end
    end
    if not self._selecting and mb == 1 then
      self._selecting = true
      self._draging = false
      self._selx1 = mx
      self._sely1 = my
      local clear = true
      for name, child in pairs(self.children) do
        local cx, cy = child:position()
        local cw, ch = child:size()
        if self:aabb(mx, my, 0, 0, cx, cy, cw, ch) then
          self._selecting = false
          self._draging = true
          if child.selected then
            clear = false
          end
          child:select()
        end
      end
      if clear then
        for name, child in pairs(self.children) do
          child:deselect()
        end
      end
    end
    if mb == 1 then
      self._selx2 = mx
      self._sely2 = my
      gfx.fgcolor(self.fgcolor)
      local x, y = math.min(self._selx1, self._selx2), math.min(self._sely1, self._sely2)
      local w, h = math.abs(self._selx1 - self._selx2), math.abs(self._sely1 - self._sely2)
      gfx.bar(x, y, w, 1)
      gfx.bar(x, y, 1, h)
      gfx.bar(x + w, y, 1, h)
      gfx.bar(x, y + h, w, 1)
    end
    if (self._selecting or self._draging) and mb == 0 then
      local x, y = math.min(self._selx1, self._selx2), math.min(self._sely1, self._sely2)
      local w, h = math.abs(self._selx1 - self._selx2), math.abs(self._sely1 - self._sely2)
      for name, child in pairs(self.children) do
        local cx, cy = child:position()
        local cw, ch = child:size()
        if self:aabb(x, y, w, h, cx, cy, cw, ch) then
          child:select()
        end
      end
      self._selecting = false
      self._draging = false
    end
    for name, child in pairs(self.children) do
      child:step(time)
    end
    view.active(prevvp)
  end
end
Icon.Board = Board

return Icon