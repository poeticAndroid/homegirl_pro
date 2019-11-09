local Role, Vector2 = require(_DIR .. "role"), require(_DIR .. "vector2")
local fonts = {}

local TextRole = Role:extend()
do
  function TextRole:draw(t)
    Role.draw(self, t)
    if not self.font then
      self.font = "victoria.8b"
    end
    if not fonts[self.font] then
      fonts[self.font] = text.loadfont(self.font)
    end
    if not self.anchor then
      self.size = Vector2:new(text.draw(self.text, fonts[self.font], self.game.size.x, self.game.size.y))
      self.anchor = self.size:multiply(.5, .5, self.anchor or Vector2:new())
    end
    self.size:set(
      text.draw(self.text, fonts[self.font], self.screenpos.x - self.anchor.x, self.screenpos.y - self.anchor.y)
    )
  end
end
return TextRole
