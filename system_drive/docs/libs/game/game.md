`game` class
============
Class to govern a game. Extend this to implement your own game-wide logic.

```lua
local G = require("game")
local game = G.Game(_DIR, 10, 4)
```

**`game.gamepads`**  
Table of gamepad objects representing the current state of gamepads. Each gamepad object has a `dir` vector and `a`, `b`, `x`, `y` properties that are either `0` or `1`. They also have a `delta` table representing the difference in state since last `step`. It's recommended to read gamepad `0` for single-player and `1` and `2` for 2-player games.

**`Game:new(gamedir, mode, colorbits[, fps]): game`**  
Create a new game with given `gamedir` for assets, screen `mode`, `colorbits` and `fps`.

**`game:step(t)`**  
Advance the game.

**`game:changescene(scenename)`**  
Change to given scene.

**`game:framerate([fps]): fps`**  
Get/set the target framerate.

**`game:playsound(soundname[, channel[, loop]])`**  
Play given sound.

