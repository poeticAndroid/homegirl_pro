`ui` classes
============
User interface widgets.

These classes extend [`Widget`](widget.md).

```lua
local UI = require("ui")
local label = UI.Label:new("Awesome")
```

`Label` class
-------------
**`Label:new(label): label`**  
Create a new label.

**`label:autosize()`**  
Set the size of the label to fit the text.

`Button` class
--------------
**`Button:new(label): button`**  
Create a new button.

**`button:autosize()`**  
Set the size of the button to fit the text (plus some margin).

`TextInput` class
-----------------
**`TextInput:new([content]): textinput`**  
Create a new text input widget.

**`textinput:setcontent(txt)`**  
Set the text content of this text input.

**`textinput:autosize()`**  
Set the size of the button to fit the text.

`Scrollbox` class
-----------------
**`Scrollbox:new(): scrollbox`**  
Create a new scroll box.
