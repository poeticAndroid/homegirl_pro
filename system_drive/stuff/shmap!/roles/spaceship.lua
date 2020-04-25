local ge = require("game")

local Spaceship = ge.Role:extend()
do
  function Spaceship:constructor(...)
    ge.Role.constructor(self, ...)
  end

  function Spaceship:step(t)
    self.velocity:set(self.game.gamepads[0].dir)
    if self.game.gamepads[0].delta.a > 0 then
      self.scene:addactor({
        costume = "bullet",
        tags = { "bullet" },
        position = { x=self.position.x, y=self:top() },
        velocity = { x=0, y=-4 },
        ttl = 100
      })
      self.game:playsound("shot", 1)
    end
    
    ge.Role.step(self, t)
  end
  
  function Spaceship:kill()
    if not self.dead then
      self:changecostume("spaceship_die", true, false, true)
      self.game:playsound("explosion", 1)
      self.game:playsound("explosion", 2)
    end
    ge.Role.kill(self)
  end
  function Spaceship:destroy()
    self.game:changescene("start")
  end
end
return Spaceship