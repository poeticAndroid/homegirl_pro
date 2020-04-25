local ge = require("game")

local Polarbear = ge.Role:extend()
do
  function Polarbear:kill()
    if not self.dead then
      self:changecostume("polarbear_die", true, false, true)
      self.game:playsound("splat", 2)
    end
    ge.Role.kill(self)
  end
end
return Polarbear
