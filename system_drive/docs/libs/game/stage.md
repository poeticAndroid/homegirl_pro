`stage` class
=============
The base class for stages and scenes. Extend this to implement your own stage logic for your scenes.

```lua
local G = require("game")
local scene = G.Stage(game, require("myscene.scene.lua"))
```

**`scene.camera`**  
Position vector for the camara.

**`scene.gravity`**  
Gravity vector.

**`scene.actorsbytag`**  
All actors of the scene grouped by tags and roles.

**`scene.actors`**  
All actors of the scene.

**`Stage:new(game, sceneobj): scene`**  
Create new scene.

**`scene:reset()`**  
Reset this scene.

**`scene:step(t)`**  
Advance this scene and all of its actors. This is called automatically by the game.

**`scene:draw(t)`**  
Draw this scene and all of its actors. This is called automatically by the game.

**`scene:enter()`**  
This is called when changing to this scene.

**`scene:exit()`**  
This is called when changing away from this scene.

**`scene:addactor(obj)`**  
Add actor to this scene.

**`scene:removeactor(actor)`**  
Remove actor from this scene.

**`scene:onoverlap(a, b, resolver[, includedead])`**  
Check for overlap between two groups of actors, and call `resolver(actor1, actor2)` for all actors who overlap.
