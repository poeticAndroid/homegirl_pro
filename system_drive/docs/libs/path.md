`path` library
==============
Miscellaneous functions to manipulate file paths.

```lua
local path = require("path")
```

**`path.split(pathname): segments`**  
Split given pathname into segments and return them in a table.

**`path.resolve(...): absolutepath`**  
Attempt to resolve given paths into one absolute path and return it.

**`path.basename(pathname): basename`**  
Return the basename of the given pathname.

**`path.dirname(pathname): dirname`**  
Return the dirname of the given pathname.

**`path.trailslash(pathname): pathwithtrailslash`**  
Ensure pathname ends with `/` or `:` and return it.

**`path.notrailslash(pathname): pathwithouttrailslash`**  
Ensure pathname doesn't end with `/` and return it.
