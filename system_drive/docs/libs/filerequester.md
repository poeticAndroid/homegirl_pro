`filerequester` class
=====================
Class for creating filerequesters. This should be attached to another widget, like a [`Screen`](screen.md) or [`Window`](window.md).

`FileRequester` extends [`Widget`](widget.md).

```lua
local FileRequester, Window = require("filerequester"), require("window")
local win

function _init()
  win = Window:new()
  win:attach("filereq", FileRequester:new("Load text file", {".txt"}, "user:myfile.txt"))
    .ondone = function(requester, filename)
      if value then
        print("You picked "..filename.."!")
      else
        print("You didn't pick anything...")
      end
    end
  view.active(win.container)
end

function _step(t)
  win:step(t)
end
```

**`FileRequester:new(title[, suffixes[, default]]): filerequester`**  
Create new file requester with given `title`, allowing only filenames ending in at least one of the `suffixes`, starting with `default`.

**`filerequester:ondone(filename)`**  
This is called when a file is selected or selection is canceled.