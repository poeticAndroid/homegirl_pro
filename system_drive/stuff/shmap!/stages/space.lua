local ge = require("game")

local Space = ge.Stage:extend()
do
  function Space:enter(...)
    self.nextbear = 0
    ge.Stage.enter(self, ...)
    for i = 1,100 do
      self:addactor({
        role = "star",
        position = {
          x = math.random(self.game.size.x)-self.game.size.x*.5,
          y = math.random(self.game.size.y)-self.game.size.y*.5
        },
        velocity = { x = 0, y = math.random() }
      })
    end
  end

  function Space:step(t)
    if t > self.nextbear then
      self:addactor({
        role = "polarbear",
        costume = "polarbear",
        tags = { "enemy" },
        position = { x = math.random(self.game.size.x)-160, y = self.game.size.y*-0.5 },
        velocity = { x = 0, y = 1 },
        ttl = self.game.size.y
      })
      self.nextbear = t + 1024
    end
    ge.Stage.step(self, t)
    self:onoverlap(self.actorsbytag["spaceship"], self.actorsbytag["enemy"], function(ship, enemy)
      ship:kill()
    end)
    self:onoverlap(self.actorsbytag["enemy"], self.actorsbytag["bullet"], function(enemy, bullet)
      bullet:destroy()
      enemy:kill()
    end)
  end
end
return Space