local Widget = require("widget")

local Icon = Widget:extend()
do
  function Icon:_new(label, iconfile)
    self.label = label
    self.icon = image.load(iconfile)
  end

  function Icon:attachto(...)
    Widget.attachto(self, ...)
    self:redraw()
  end

  function Icon:step(time)
    local prevvp = view.active()
    view.active(self.container)
    local iw, ih = image.size(self.icon[1])
    local mx, my, mb = input.mouse()
    if mb == 1 then
      self.dragged = true
      view.active(self.parentvp)
      mx, my, mb = input.mouse()
      self:position(mx - iw / 2, my - ih / 2)
    else
      self.dragged = false
    end
    view.active(prevvp)
  end

  function Icon:redraw()
    local vw, vh = view.size(self.container)
    local iw, ih = image.size(self.icon[1])
    local tw, th = text.draw(self.label, self.font)
    view.size(self.container, math.max(iw, tw), ih + th + 1)
    vw, vh = view.size(self.container)
    gfx.cls()
    gfx.fgcolor(self.fgtextcolor)
    image.draw(self.icon[1], vw / 2 - iw / 2, 0, 0, 0, iw, ih)
    text.draw(self.label, self.font, vw / 2 - tw / 2, ih + 1)
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
    if name then
      self.children[name] = child
    else
      table.insert(self.children, child)
    end
    child:attachto(self.container, self.screen)
    return child
  end

  function Board:step(time)
    local prevvp = view.active()
    view.active(self.container)
    local mx, my, mb = input.mouse()
    local drop = input.drop()
    if drop then
      local icon = self:attach(nil, Icon:new("Icon", _DRIVE .. "icons/gif.gif"))
      local iw, ih = image.size(icon.icon[1])
      icon:position(mx - iw / 2, my - ih / 2)
    end
    self:size(view.size(self.parentvp))
    for name, child in pairs(self.children) do
      child:step(time)
      if child.dragged then
        input.drag(child.object or child.label, child.icon[1])
        self:destroychild(name)
      end
    end
    view.active(prevvp)
  end
end
Icon.Board = Board

return Icon
