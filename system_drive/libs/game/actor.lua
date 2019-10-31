local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Actor = Object:extend()
do
  function Actor:constructor(scene, properties)
    self.scene = scene
    self.game = scene.game
    self.frame = 1
    self.shape = "aabb"
    self.position = Vector2:new()
    self.velocity = Vector2:new(0, 0)
    self.gravity = Vector2:new(0, 0)
    self.momentum = 1
    self.bounce = 0.5
    self.friction = 0
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
    if self.momentum > 0 then
      self.velocity:add(self.scene.gravity):add(self.gravity)
      if self.friction > 0 then
        local mag = self.velocity.magnitude()
        if mag > self.friction then
          self.velocity.magnitude(mag - self.friction)
        else
          self.velocity.set(0, 0)
        end
      end
      self.velocity:multiply(self.momentum)
      self.position:add(self.velocity)
    end
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
    self.anchor = self.size:multiply(.5, .5, self.anchor or Vector2:new())
    self.frame = 1
  end

  function Actor:left(left)
    if left then
      self.position.x = left + self.anchor.x
    end
    return self.position.x - self.anchor.x
  end
  function Actor:right(right)
    if right then
      self.position.x = right - self.size.x + self.anchor.x
    end
    return self.position.x - self.anchor.x + self.size.x
  end
  function Actor:top(top)
    if top then
      self.position.y = top + self.anchor.y
    end
    return self.position.y - self.anchor.y
  end
  function Actor:bottom(bottom)
    if bottom then
      self.position.y = bottom - self.size.y + self.anchor.y
    end
    return self.position.y - self.anchor.y + self.size.y
  end
  function Actor:radius(radius)
    if radius then
      self.size.set(radius * 2)
    end
    return self.size.x / 2
  end
  function Actor:overlapswith(actor)
    if self.shape == "circle" then
      self:_overlapcircles(
        self.position.x,
        self.position.y,
        self.radius(),
        actor.position.x,
        actor.position.y,
        actor.radius()
      )
    else
      return self:_overlap2D(
        self.top(),
        self.left(),
        self.bottom(),
        self.right(),
        actor.top(),
        actor.left(),
        actor.bottom(),
        actor.right()
      )
    end
  end

  function Actor:_overlap1D(a1, a2, b1, b2)
    return math.max(a1, a2) > math.min(b1, b2) and math.min(a1, a2) < math.max(b1, b2)
  end
  function Actor:_overlap2D(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
    return self:_overlap1D(ax1, ax2, bx1, bx2) and self:_overlap1D(ay1, ay2, by1, by2)
  end
  function Actor:_overlapcircles(x1, y1, r1, x2, y2, r2)
    local l = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
    return l < r1 + r2
  end
end
return Actor
