local ge = require("game")

local Star = ge.Role:extend()
do
  function Star:step(t)
    ge.Role.step(self, t)
    if self.position.y > self.game.size.y/2 then
      self.position:subtract(0, self.game.size.y)
    end
  end
  function Star:draw(t)
    ge.Role.draw(self, t)
    gfx.fgcolor(8)
    gfx.plot(self.screenpos:get())
  end
end
return Star
