`menu` class
============
Class to create drop-down menus.

`Menu` extends [`Widget`](widget.md).

```lua
local Menu = require("menu")
local menu = Menu:new({
  {label = "File", menu = {
    {label = "Load..", hotkey = "l", action = reqload},
    {label = "Quit", hotkey = "q", action = quit},
  }},
  {label = "Options", onopen = updateoptions, menu = {
    {label = "High", action = sethigh},
    {label = "Low", action = setlow, checked = true},
  }}
})
```

**`Menu:new(struct)`**  
Create new pull-down menu. This should be attached to a [`Window`](window.md) or [`Screen`](screen.md).
