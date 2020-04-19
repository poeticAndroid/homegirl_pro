`window` class
==============
Class to make windows that can be dragged and stuff.

`Window` is extended from [`Widget`](widget.md).

```lua
local Window = require("window")
local window = Window:new("Window title", 8,16, 320, 90)
```

**`Window:new(title, left, top, width, height, parent): window`**  
Create a new window

**`window:title([title]): title`**  
Get/set the title of this window.

**`window:icon([iconfile]): iconfile`**  
Get/set the icon file of this window. This might be shown by another program governing the windows.

**`window:position([left, top]): left, top`**  
Get/set the position of this window.

**`window:size([width, height]): height, height`**  
Get/set the size of this window.

**`window:step(time)`**  
Advance the window. This is called automatically by the parent, if its attached to one.
