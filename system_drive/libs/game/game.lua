local Object = require("object")
local Vector2 = require(_DIR .. "vector2")

local Game = Object:extend()
do
  function Game:constructor(dir, mode, colorbits, fps)
    self.gamedir = dir
    self.screenmode = mode
    self.colorbits = colorbits
    self.targetfps = fps
    self.gamepads = {
      self:_newgamepad(),
      self:_newgamepad()
    }
    self.gamepads[0] = self:_newgamepad()
    sys.stepinterval(0)
  end

  function Game:step(t)
    if self.scene then
      local sc = self.scene
      for i, pad in pairs(self.gamepads) do
        self:_handlegamepad(i)
      end
      sc:step(t)
      sc:draw(t)
      if input.hotkey() == "\x1b" then
        if sc ~= self.scenes["start"] then
          self:changescene("start")
        else
          return sys.exit()
        end
      end
      if input.hotkey() == "." then
        view.zindex(self.screen, 0)
        view.focused(self.screen, false)
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
      elseif not self.roles then
        self.roles = {role = require(_DIR .. "role"), text = require(_DIR .. "textrole")}
        self._assets.roles = fs.list(self.gamedir .. "roles/")
        if self._assets.roles and #(self._assets.roles) > 0 then
          print("Loading roles...")
        end
      elseif self._assets.roles and #(self._assets.roles) > 0 then
        local file = table.remove(self._assets.roles)
        if string.sub(file, -4) == ".lua" then
          self.roles[string.sub(file, 1, -5)] = require(self.gamedir .. "roles/" .. file)
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
        if string.sub(file, -10) == ".scene.lua" then
          local scene = require(self.gamedir .. "scenes/" .. file)
          self.scenes[string.sub(file, 1, -11)] = self.stages[scene.stage or "stage"]:new(self, scene)
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
    image.copymode(3, true)
    self:framerate(self.targetfps or 50)
    image.pointer(image.new())
    self:changescene("start")
  end

  function Game:changescene(scenename)
    print("Scene: " .. scenename)
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

  function Game:playsound(soundname, channel, loop)
    if not channel then
      self._lastchan = self._lastchan or 0
      self._lastchan = self._lastchan + 1
      channel = self._lastchan
    end
    audio.play(channel, self.sounds[soundname])
    if loop ~= nil then
      if loop then
        audio.channelloop(channel, 0, audio.samplelength(self.sounds[soundname]))
      else
        audio.channelloop(channel, 0, 0)
      end
    end
  end

  function Game:_newgamepad()
    return {
      delta = {
        dir = Vector2:new(),
        a = 0,
        b = 0,
        x = 0,
        y = 0
      },
      dir = Vector2:new(),
      _dir = Vector2:new(),
      a = 0,
      _a = 0,
      b = 0,
      _b = 0,
      x = 0,
      _x = 0,
      y = 0,
      _y = 0
    }
  end
  function Game:_handlegamepad(player)
    local gamepad = input.gamepad(player)
    -- player = player + 1
    self.gamepads[player].dir:set(0, 0)
    if gamepad & 1 > 0 then
      self.gamepads[player].dir:add(1, 0)
    end
    if gamepad & 2 > 0 then
      self.gamepads[player].dir:add(-1, 0)
    end
    if gamepad & 4 > 0 then
      self.gamepads[player].dir:add(0, -1)
    end
    if gamepad & 8 > 0 then
      self.gamepads[player].dir:add(0, 1)
    end
    if gamepad & 16 > 0 then
      self.gamepads[player].a = 1
    else
      self.gamepads[player].a = 0
    end
    if gamepad & 32 > 0 then
      self.gamepads[player].b = 1
    else
      self.gamepads[player].b = 0
    end
    if gamepad & 64 > 0 then
      self.gamepads[player].x = 1
    else
      self.gamepads[player].x = 0
    end
    if gamepad & 128 > 0 then
      self.gamepads[player].y = 1
    else
      self.gamepads[player].y = 0
    end

    self.gamepads[player].delta.dir:set(self.gamepads[player].dir):subtract(self.gamepads[player]._dir)
    self.gamepads[player].delta.a = self.gamepads[player].a - self.gamepads[player]._a
    self.gamepads[player].delta.b = self.gamepads[player].b - self.gamepads[player]._b
    self.gamepads[player].delta.x = self.gamepads[player].x - self.gamepads[player]._x
    self.gamepads[player].delta.y = self.gamepads[player].y - self.gamepads[player]._y

    self.gamepads[player]._dir:set(self.gamepads[player].dir:get())
    self.gamepads[player]._a = self.gamepads[player].a
    self.gamepads[player]._b = self.gamepads[player].b
    self.gamepads[player]._x = self.gamepads[player].x
    self.gamepads[player]._y = self.gamepads[player].y
  end
end
return Game
