local ge = require("game")
local game

local Shmap = ge.Game:extend()
do
  function Shmap:start(...)
    ge.Game.start(self, ...)
    self:playsound("powerstyx", 0, true)
    self:playsound("powerstyx", 3, true)
  end
end

function _init()
  game = Shmap:new(_DIR, 10, 5)
end

function _step(t)
  game:step(t)
end
