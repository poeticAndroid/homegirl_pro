local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Stage = Object:extend()
do
  function Stage:constructor(game, scene)
    self.game = game
    self.scene = scene
    self.camera = Vector2:new(0, 0)
  end
  function Stage:reset()
    self.actors = {}
    if self.scene.palette then
      image.usepalette(self.game.costumes[self.scene.palette][1])
    end
    if self.scene.bgcolor then
      gfx.bgcolor(self.scene.bgcolor)
    end
    for i, actor in ipairs(self.scene.actors) do
      table.insert(self.actors, self.game.actors[actor.type or "actor"]:new(self, actor))
    end
  end

  function Stage:step(t)
    for i, actor in ipairs(self.actors) do
      actor:step(t)
    end
  end
  function Stage:draw(t)
    if self.scene.bgcolor then
      gfx.cls()
    end
    for i, actor in ipairs(self.actors) do
      actor:draw(t)
    end
  end

  function Stage:enter()
    self:reset()
  end
  function Stage:exit()
  end
end
return Stage
