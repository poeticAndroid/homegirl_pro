`role` class
============
The base class for roles and actors. Extend this to implement your own role logic for your actors.

```lua
local G = require("game")
local actor = G.Role(scene, {position={x=10,y=20})
```

**`actor.game`**  
The game this actor is running on.

**`actor.frame`**  
The frame of the costume currently being displayed.

**`actor.shape`**  
The shape of this actor. Can be `"aabb"` or `"circle"`.

**`actor.scale`**  
The scale vector of this actor.

**`actor.position`**  
The position vector of this actor.

**`actor.velocity`**  
The velocity vector of this actor.

**`actor.gravity`**  
The gravity vector of this actor in addition to the gravity of the scene.

**`actor.size`**  
The size vector of this actor.

**`actor.anchor`**  
The anchor vector of this actor. 

**`actor.momentum`**  
The momentum of this actor.

**`actor.bounce`**  
The bounce of this actor.

**`actor.friction`**  
The friction of this actor.

**`actor.z`**  
The Z index of this actor.

**`actor.tags`**  
Table of tags for this actor, in addition to its rolename.

**`Role:new(scene, properties): actor`**  
Create new actor in given `scene` with given table of `properties`.

**`actor:step(t)`**  
Advance this actor. This is usually called automatically by the scene.

**`actor:deadstep(t)`**  
Advance this actor if dead. This is usually called automatically by the scene.

**`actor:draw(t)`**  
Draw this actor. This is usually called automatically by the scene.

**`actor:changecostume(name[, animate[, loop[, destroy]]])`**  
Change costume of this actor and specify whether or not to animate it, loop it or destroy the actor once the animation finishes.

**`actor:kill()`**  
Make this actor dead.

**`actor:revive()`**  
Make this actor alive.

**`actor:destroy()`**  
Remove this actor from the scene.

**`actor:left([left]): left`**  
Get/set the X coordinate of the left side of this actor.

**`actor:right([right]): right`**  
Get/set the X coordinate of the right side of this actor.

**`actor:top([top]): top`**  
Get/set the Y coordinate of the top of this actor.

**`actor:bottom([bottom]): bottom`**  
Get/set the Y coordinate of the bottom of this actor.

**`actor:radius([radius]): radius`**  
Get/set the radius of this actor.

**`actor:overlapswith(actor): isoverlapping`**  
Check if this actor is overlapping with another given actor.

**`actor:snaptoedge(actor, overlap)`**  
Move this actor close to another with given amount of overlap.
