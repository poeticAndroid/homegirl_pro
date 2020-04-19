`icon` classes
==============
Classes for making icons and something to put them on.

```lua
local Icon = require("icon")
local board = Icon.Board:new()
board.attach("dropped", Icon:new("My icon", "iconfile.gif"))
```

`Icon` class
------------
`Icon` extends [`Widget`](widget.md).

**`Icon:new(label, iconfile): icon`**  
Create new icon with given label and filename for icon. The iconfile should be a `.gif` file of two frames. First frame is normal state, second frame is selected state.

**`icon:select()`**  
Mark this icon as selected.

**`icon:deselect()`**  
Mark this icon as unselected.


`Board` class
-------------
`Board` extends [`Widget`](widget.md).

**`Board:new(): board`**  
Create new icon board.

**`board:tidy()`**  
Tidy up the icons on this board.

**`board:getselected(): selected`**  
Get all the currently selected icons on this board.

**`board:ondrop(drop): accepted`**  
This gets called when something is dropped on this board.

