local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Role = Object:extend()
do
  function Role:constructor(scene, properties)
    self.scene = scene
    self.play = scene.play
    self.frame = 1
    self.shape = "aabb"
    self.scale = Vector2:new(1, 1)
    self.position = Vector2:new()
    self.velocity = Vector2:new(0, 0)
    self.gravity = Vector2:new(0, 0)
    self.momentum = 1
    self.bounce = 0.5
    self.friction = 0
    self.z = 0
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
    self.screenpos = Vector2:new()
  end

  function Role:step(t)
    if self.momentum > 0 then
      self.velocity:add(self.scene.gravity):add(self.gravity)
      if self.friction > 0 then
        local mag = self.velocity:magnitude()
        if mag > self.friction then
          self.velocity:magnitude(mag - self.friction)
        else
          self.velocity:set(0, 0)
        end
      end
      self.velocity:multiply(self.momentum)
      self.position:add(self.velocity)
    end
    if self.ttl then
      self.ttl = self.ttl - 1
      if self.ttl == 0 then
        self:destroy()
      end
    end
  end
  function Role:deadstep(t)
    Role.step(self, t)
  end
  function Role:draw(t)
    self.screenpos:set(self.play.size):multiply(0.5):subtract(self.scene.camera):add(self.position)
    if self.costume then
      if not self._nextframe then
        self._nextframe = t + image.duration(self.costume[self.frame])
      end
      if t >= self._nextframe and self.animatecostume then
        self.frame = self.frame + 1
        if self.frame > #(self.costume) then
          if self.finalcostume then
            self:destroy()
          end
          if self.loopcostume then
            self.frame = 1
          else
            self.frame = #(self.costume)
          end
        end
        self._nextframe = self._nextframe + image.duration(self.costume[self.frame])
      end
      image.draw(
        self.costume[self.frame],
        self.screenpos.x - self.anchor.x * self.scale.x,
        self.screenpos.y - self.anchor.y * self.scale.y,
        0,
        0,
        self.size.x * self.scale.x,
        self.size.y * self.scale.y,
        self.size.x,
        self.size.y
      )
    end
  end

  function Role:changecostume(name, animate, loop, destroy)
    if animate == nil then
      animate = true
    end
    if loop == nil then
      loop = true
    end
    self.animatecostume = animate
    self.loopcostume = loop
    self.finalcostume = destroy
    self.costume = self.play.costumes[name]
    self.size = Vector2:new(image.size(self.costume[self.frame]))
    self.anchor = self.size:multiply(.5, .5, self.anchor or Vector2:new())
    self.frame = 1
    self._nextframe = nil
  end
  function Role:kill()
    self.dead = true
  end
  function Role:revive()
    self.dead = false
  end
  function Role:destroy()
    self.destroyed = true
  end

  function Role:left(left)
    if left then
      self.position.x = left + self.anchor.x
    end
    return self.position.x - self.anchor.x
  end
  function Role:right(right)
    if right then
      self.position.x = right - self.size.x + self.anchor.x
    end
    return self.position.x - self.anchor.x + self.size.x
  end
  function Role:top(top)
    if top then
      self.position.y = top + self.anchor.y
    end
    return self.position.y - self.anchor.y
  end
  function Role:bottom(bottom)
    if bottom then
      self.position.y = bottom - self.size.y + self.anchor.y
    end
    return self.position.y - self.anchor.y + self.size.y
  end
  function Role:radius(radius)
    if radius then
      self.size.set(radius * 2)
    end
    return self.size.x / 2
  end
  function Role:overlapswith(actor)
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
        self:top(),
        self:left(),
        self:bottom(),
        self:right(),
        actor:top(),
        actor:left(),
        actor:bottom(),
        actor:right()
      )
    end
  end
  function Role:snaptoedge(obstruction, overlap)
    local x, y, l = 0, math.maxinteger
    if self.shape == "circle" then
      x = self.position.x - obstruction.position.x
      y = self.position.y - obstruction.position.y
      l = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
      l = l / (self.radius() + obstruction.radius() - overlap)
      x = x / l
      y = y / l
      self.position.set(obstruction.position.get()).add(x or 0, y or 0)
    else
      if (math.abs(x + y) > math.abs(obstruction:right() - self:left())) then
        x = obstruction:right() - self:left() - overlap
        y = 0
      end
      if (math.abs(x + y) > math.abs(obstruction:left() - self:right())) then
        x = obstruction:left() - self:right() + overlap
        y = 0
      end
      if (math.abs(x + y) > math.abs(obstruction:bottom() - self:top())) then
        x = 0
        y = obstruction:bottom() - self:top() - overlap
      end
      if (math.abs(x + y) > math.abs(obstruction:top() - self:bottom())) then
        x = 0
        y = obstruction:top() - self:bottom() + overlap
      end
      self.position.add(x, y)
    end
  end

  function Role:_overlap1D(a1, a2, b1, b2)
    return math.max(a1, a2) > math.min(b1, b2) and math.min(a1, a2) < math.max(b1, b2)
  end
  function Role:_overlap2D(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
    return self:_overlap1D(ax1, ax2, bx1, bx2) and self:_overlap1D(ay1, ay2, by1, by2)
  end
  function Role:_overlapcircles(x1, y1, r1, x2, y2, r2)
    local l = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
    return l < r1 + r2
  end
end
return Role
