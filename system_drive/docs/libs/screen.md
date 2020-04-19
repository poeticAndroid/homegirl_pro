`Screen` class
==============
Class to make screens with titles, that can be dragged and put behind other screens.

`Screen` is extended from [`Widget`](widget.md).

```lua
local Screen = require("screen")
local screen = Screen:new("Screen title", 11, 3)
```

**`Screen:new(title, mode, colorbits): screen`**  
Create a new draggable screen.

**`screen:attachwindow(name, child)`**  
Attach a [`Window`](window.md) to this screen.

**`screen:font([font]): font`**  
Get/set the font for this screen.

**`screen:title([title]): title`**  
Get/set the title for this screen.

**`screen:step(time)`**  
Advance this screen and all attached widgets.

**`screen:top([top]): top`**  
Get/set the position of this screen.

**`screen:size(): width, height`**  
Get the size of the main viewport of this screen.

**`screen:mode([mode, colorbits]): mode, colorbits`**  
Get/set the screen mode and colorbits of this screen.

**`screen:colors(bg, fg)`**  
Set the background and foreground colors of the titlebar.
