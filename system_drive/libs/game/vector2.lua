local Object = require("object")

local Vector2 = Object:extend()
do
  function Vector2:constructor(x, y)
    self:set(x, y)
  end

  function Vector2:get()
    return self.x, self.y
  end
  function Vector2:set(x, y, result)
    if type(x) == "table" then
      result = result or y or self
      y = x.y
      x = x.x
    else
      result = result or self
      y = y or x
    end
    result.x = x or 0
    result.y = y or 0
    return result
  end

  function Vector2:add(x, y, result)
    if type(x) == "table" then
      result = result or y or self
      y = x.y
      x = x.x
    else
      result = result or self
      y = y or x
    end
    result.x = self.x + x
    result.y = self.y + y
    return result
  end
  function Vector2:subtract(x, y, result)
    if type(x) == "table" then
      result = result or y or self
      y = x.y
      x = x.x
    else
      result = result or self
      y = y or x
    end
    result.x = self.x - x
    result.y = self.y - y
    return result
  end
  function Vector2:multiply(x, y, result)
    if type(x) == "table" then
      result = result or y or self
      y = x.y
      x = x.x
    else
      result = result or self
      y = y or x
    end
    result.x = self.x * x
    result.y = self.y * y
    return result
  end
end
return Vector2
