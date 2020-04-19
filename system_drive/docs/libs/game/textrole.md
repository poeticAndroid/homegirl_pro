`textrole` class
================
Role for printing text on the screen.

`TextRole` extends [`Role`](role.md).

```lua
local G = require("game")
local actor = G.TextRole(scene, {position={x=10,y=20, text="Hello world!"})
```

**`actor.text`**  
The text to be displayed.

**`actor.font`**  
The fontname to use to display the text.

**`actor.copymode`**  
The text copymode to use.
