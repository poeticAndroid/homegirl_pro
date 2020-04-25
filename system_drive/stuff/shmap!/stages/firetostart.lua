local ge = require("game")

local FireToStart = ge.Stage:extend()
do
  function FireToStart:step(t)
    self.camera:set(math.sin(t/1024)*8,-math.cos(t/768)*8)
    ge.Stage.step(self, t)
    if self.game.gamepads[0].delta.a < 0 then
      self.game:changescene("game")
    end
  end
end
return FireToStart
