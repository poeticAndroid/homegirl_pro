`object` class
==============
This is the ultimate super class!

```lua
local Object = require("object")

local Animal = Object:extend()
do
  function Animal:constructor(name, sound)
    self.name = name
    self.sound = sound
  end
  function Animal:speak()
    print("My name is "..self.name.." and I say "..self.sound.."!")
  end
end

local Cat = Animal:extend()
do
  function Cat:constructor(name)
    Animal.constructor(self, name, "miaow")
  end
end
```

**`Object:constructor()`**  
This is called by `:new` to initiate a new object.

**`Object:new(...): object`**  
Create a new instance of this class and initiate it.

**`Object:extend(): SubClass`**  
Create a new subclass of this class, ready for extension.
