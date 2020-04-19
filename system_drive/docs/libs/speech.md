`speech` class
==============
Speech synthesis for Homegirl.

```lua
local Speech = require("speech")
local talker = Speech:new()
```

**`talker.samples = {}`**  
Table of the phoneme samples.

**`talker.dictionary = {}`**  
Table of the dictionary to translate words into phonemes.

**`Speech:new([voicefile[, dictfile]]): talker`**  
Create a new speech instance with given voice file and dictionary loaded.

**`talker:loadvoice(voicefile)`**  
Load another voice file.

**`talker:loaddictionary(dictfile)`**  
Add another dictionary.

**`talker:texttophones(text): phones`**  
Translate text into a table of phonemes.

**`talker:renderspeech(phones): sample`**  
Render given phonemes into an audio sample.

