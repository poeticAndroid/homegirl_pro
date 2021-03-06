local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Stage = Object:extend()
do
  function Stage:constructor(game, scene)
    self.game = game
    self.scene = scene
    self._destroyedactors = {}
  end
  function Stage:reset()
    self.camera = Vector2:new(self.scene.camera)
    self.gravity = Vector2:new(self.scene.gravity)
    self.actorsbytag = {}
    self.actors = {}
    if self.scene.palette then
      image.usepalette(self.game.costumes[self.scene.palette][1])
    end
    if self.scene.bgcolor then
      gfx.bgcolor(self.scene.bgcolor)
    end
    for i, actor in ipairs(self.scene.actors) do
      self:addactor(actor)
    end
    if self.scene.music then
      self.game:changemusic(self.scene.music)
    end
  end

  function Stage:step(t)
    for i, actor in ipairs(self.actors) do
      if actor.dead then
        actor:deadstep(t)
      else
        actor:step(t)
      end
      if actor.destroyed then
        table.insert(self._destroyedactors, actor)
      elseif i > 1 and actor.z < self.actors[i - 1].z then
        self.actors[i] = self.actors[i - 1]
        self.actors[i - 1] = actor
      end
    end
    while #(self._destroyedactors) > 0 do
      self:removeactor(table.remove(self._destroyedactors))
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

  function Stage:addactor(obj)
    local actor = self.game.roles[obj.role or "role"]:new(self, obj)
    self.actorsbytag[actor.role or "role"] = self.actorsbytag[actor.role or "role"] or {}
    table.insert(self.actorsbytag[actor.role or "role"], actor)
    if actor.tags then
      for i, tag in ipairs(actor.tags) do
        self.actorsbytag[tag] = self.actorsbytag[tag] or {}
        table.insert(self.actorsbytag[tag], actor)
      end
    end
    table.insert(self.actors, actor)
    return actor
  end
  function Stage:removeactor(actor, from)
    if from then
      for i, val in ipairs(from) do
        if val == actor then
          table.remove(from, i)
        end
      end
    else
      self:removeactor(actor, self.actors)
      self:removeactor(actor, self.actorsbytag[actor.role or "role"])
      if actor.tags then
        for i, tag in ipairs(actor.tags) do
          self:removeactor(actor, self.actorsbytag[tag])
        end
      end
    end
  end

  function Stage:onoverlap(a, b, resolver, includedead)
    if not (a and b and resolver) then
      return
    end
    if a.scene then
      a = {a}
    end
    if b.scene then
      b = {b}
    end
    for i1, actor1 in ipairs(a) do
      if includedead or not actor1.dead then
        for i2, actor2 in ipairs(b) do
          if includedead or not actor2.dead then
            if (actor1 ~= actor2 and actor1:overlapswith(actor2)) then
              resolver(actor1, actor2)
            end
          end
        end
      end
    end
  end
end
return Stage
