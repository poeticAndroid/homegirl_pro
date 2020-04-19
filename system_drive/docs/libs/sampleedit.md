`sampleedit` library
====================
Miscellaneous functions to manipulate audio samples.

```lua
local SampleEdit = require("sampleedit")
```

**`SampleEdit.getvalue(sampl, pos): value`**  
Get value of given sample at given position. If `pos` is not an integer, the value will get interpolated between the two nearest sample points.

**`SampleEdit.copy = function(src, dest[, srcpos[, srclen[, destpos[, destlen]]]]): dest`**  
Copy audio from one sample to another.

**`SampleEdit.fade = function(sampl, startval, endval[, pos, length]): sampl`**  
Change the volume from `startval` to `endval` during given range.


**`SampleEdit.xfade = function(src, dest, startval, endval, srcpos, srclen, destpos): dest`**  
Crossfade between two samples. 

**`SampleEdit.normalize = function(sampl[, maxval[, pos, length]])`**  
Normalize volume in sample.

**`SampleEdit.straightpitch = function(sampl, dest, samsperhz[, pos, length]): dest`**  
Straighten the pitch of a sample, so that it will have a fixed number of samples per hertz.
