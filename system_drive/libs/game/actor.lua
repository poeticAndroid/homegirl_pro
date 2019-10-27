local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Actor = Object:extend()
do
  function Actor:constructor(scene, properties)
    self.scene = scene
    self.game = scene.game
    self.frame = 1
    self.position = Vector2:new()
    self.velocity = Vector2:new(0, 0)
    for name, val in pairs(properties) do
      if type(self[name]) == "function" then
        self[name](val)
      elseif type(self[name]) == "table" then
        for _name, _val in pairs(val) do
          self[name][_name] = _val
        end
      else
        self[name] = val
      end
    end
    if type(self.costume) == "string" then
      self:changecostume(self.costume)
    end
    self._screenpos = Vector2:new()
  end

  function Actor:step(t)
    self.position:add(self.velocity)
  end
  function Actor:draw(t)
    self._screenpos:set(self.game.size):multiply(.5):add(self.position):subtract(self.anchor):subtract(
      self.scene.camera
    )
    image.draw(self.costume[self.frame], self._screenpos.x, self._screenpos.y, 0, 0, self.size:get())
  end

  function Actor:changecostume(name)
    self.costume = self.game.costumes[name]
    self.size = Vector2:new(image.size(self.costume[self.frame]))
    self.anchor = self.size:multiply(.5, .5, Vector2:new())
    self.frame = 1
  end
end
return Actor
