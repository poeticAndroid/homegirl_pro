local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Game = Object:extend()
do
  function Game:constructor(dir, mode, colorbits, fps)
    self.gamedir = dir
    self.screenmode = mode
    self.colorbits = colorbits
    self.targetfps = fps
    sys.stepinterval(0)
  end

  function Game:step(t)
    if self.scene then
      self.scene:step(t)
      self.scene:draw(t)
      if input.hotkey() == "\x1b" then
        if self.scene ~= self.scenes["start"] then
          self:changescene("start")
        else
          return sys.exit()
        end
      end
    else
      self._assets = self._assets or {}
      if not self.costumes then
        self.costumes = {}
        self._assets.costumes = fs.list(self.gamedir .. "costumes/")
        if self._assets.costumes and #(self._assets.costumes) > 0 then
          print("Loading costumes...")
        end
      elseif self._assets.costumes and #(self._assets.costumes) > 0 then
        local file = table.remove(self._assets.costumes)
        if string.sub(file, -4) == ".gif" then
          self.costumes[string.sub(file, 1, -5)] = image.load(self.gamedir .. "costumes/" .. file)
          print("  " .. file)
        end
      elseif not self.sounds then
        self.sounds = {}
        self._assets.sounds = fs.list(self.gamedir .. "sounds/")
        if self._assets.sounds and #(self._assets.sounds) > 0 then
          print("Loading sounds...")
        end
      elseif self._assets.sounds and #(self._assets.sounds) > 0 then
        local file = table.remove(self._assets.sounds)
        if string.sub(file, -4) == ".wav" then
          self.sounds[string.sub(file, 1, -5)] = audio.load(self.gamedir .. "sounds/" .. file)
          print("  " .. file)
        end
      elseif not self.actors then
        self.actors = {actor = require(_DIR .. "actor")}
        self._assets.actors = fs.list(self.gamedir .. "actors/")
        if self._assets.actors and #(self._assets.actors) > 0 then
          print("Loading actors...")
        end
      elseif self._assets.actors and #(self._assets.actors) > 0 then
        local file = table.remove(self._assets.actors)
        if string.sub(file, -4) == ".lua" then
          self.actors[string.sub(file, 1, -5)] = require(self.gamedir .. "actors/" .. file)
          print("  " .. file)
        end
      elseif not self.stages then
        self.stages = {stage = require(_DIR .. "stage")}
        self._assets.stages = fs.list(self.gamedir .. "stages/")
        if self._assets.stages and #(self._assets.stages) > 0 then
          print("Loading stages...")
        end
      elseif self._assets.stages and #(self._assets.stages) > 0 then
        local file = table.remove(self._assets.stages)
        if string.sub(file, -4) == ".lua" then
          self.stages[string.sub(file, 1, -5)] = require(self.gamedir .. "stages/" .. file)
          print("  " .. file)
        end
      elseif not self.scenes then
        self.scenes = {}
        self._assets.scenes = fs.list(self.gamedir .. "scenes/")
        if self._assets.scenes and #(self._assets.scenes) > 0 then
          print("Loading scenes...")
        end
      elseif self._assets.scenes and #(self._assets.scenes) > 0 then
        local file = table.remove(self._assets.scenes)
        if string.sub(file, -4) == ".lua" then
          local scene = require(self.gamedir .. "scenes/" .. file)
          self.scenes[string.sub(file, 1, -5)] = self.stages[scene.stage or "stage"]:new(self, scene)
          print("  " .. file)
        end
      else
        self:start()
      end
    end
  end

  function Game:start()
    self.screen = view.newscreen(self.screenmode, self.colorbits)
    self.size = Vector2:new(view.size(self.screen))
    self:framerate(self.targetfps or 60)
    self:changescene("start")
  end

  function Game:changescene(scenename)
    if not self.scenes[scenename] then
      print("Scene '" .. scenename .. "' not found!")
      return sys.exit(404)
    end
    if self.scene then
      self.scene:exit()
    end
    self.scene = self.scenes[scenename]
    self.scene:enter()
  end

  function Game:framerate(fps)
    if fps then
      self.targetfps = fps
      sys.stepinterval(1000 / fps)
    end
    return self.targetfps
  end
end
return Game
