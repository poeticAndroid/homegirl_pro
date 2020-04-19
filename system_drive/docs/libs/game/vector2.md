`vector2` class
===============
Two-dimensional vector class.

```lua
local G = require("game")
local vector = G.Vector2(16, -32)
```

**`Vector2:new(x, y): vector`**  
**`Vector2:new(vector): vector`**  
Create a new vector with given coordinates.

**`vector:get(): x, y`**  
Get X and Y coordinates of vector.

**`vector:set(x, y[, result]): result`**  
**`vector:set(vector[, result]): result`**  
Set coordinates of vector.

**`vector:add(x, y[, result]): result`**  
**`vector:add(vector[, result]): result`**  
Add a vector to this vector.

**`vector:subtract(x, y[, result]): result`**  
**`vector:subtract(vector[, result]): result`**  
Subtract a vector from this vector.

**`vector:multiply(x, y[, result]): result`**  
**`vector:multiply(vector[, result]): result`**  
Multiply a vector to this vector.

**`vector:magnitude([result]): result`**  
Get/set magnitude of this vector.
