`Widget` class
==============
Superclass for all UI widgets.

```lua
local Widget = require("widget")
local MyWidget = Widget:extend()
```

**`widget.darkcolor`**  
**`widget.lightcolor`**  
**`widget.fgcolor`**  
**`widget.bgcolor`**  
**`widget.fgtextcolor`**  
**`widget.bgtextcolor`**  
Color indexes for basic UI colors.

**`widget.parent`**  
The widget this widget is attached to.

**`widget.font`**  
Font for this widget.

**`widget:attach(name, child):child`**  
Attach another widget to this widget.


**`widget:attachto(parent[, vp, screen])`**  
Attach this widget to another widget or viewport (and create any viewports needed).

**`widget:destroy()`**  
Destroy this widget.

**`widget:destroychild(name)`**  
Destroy a child of this widget.

**`widget:position([left, top]): left, top`**  
Get/set the position of this widget.

**`widget:size([width, height]): width, height`**  
Get/set the size of this widget.

**`widget:autocolor()`**  
Automatically set the UI colors of this widget.

**`widget:focus()`**  
Make sure this widget has focus.

**`widget:step(t)`**  
Advance this widget. This gets called automatically by its parent.

**`widget:redraw()`**  
Redraw this widget.

**`Widget:outset(x, y, w, h)`**  
Static method to draw an outsetted box.

**`Widget:inset(x, y, w, h)`**  
Static method to draw an insetted box.

**`Widget:aabb(x1, y1, w1, h1, x2, y2, w2, h2): isoverlapping`**  
Static method to do AABB collision detection.

**`Widget:gotclicked(vp): gotclicked`**  
Static method to check if given viewport just got clicked.
