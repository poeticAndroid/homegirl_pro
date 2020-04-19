`modplayer` class
=================
Class for playing `.mod` files.

```lua
local ModPlayer = require("modplayer")
local player = ModPlayer("comic_bakery.mod")
```

**`ModPlayer:new(filename): player`**  
Create a new player and prepare it to play given file.

**`player:destroy()`**  
Destroy this player.

**`player:restart()`**  
Rewind to the beginning.

**`player:jumpto(pos[, div])`**  
Jump to a given position and division.

**`player:stop()`**  
Silence all audio channels.

**`player:step(t)`**  
Advance the player to keep playing.
