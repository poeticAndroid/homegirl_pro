local Speech = require("speech")
local talker

function _init(args)
  talker = Speech:new()
  print("Ready...")
end

function _step(t)
  local line = readln()
  if line then
    audio.play(1, talker:renderspeech(talker:texttophones(line)))
  end
end

local _line = ""
function readln()
  local line
  _line = _line .. sys.read()
  if string.sub(_line, -1) == "\n" then
    line = string.sub(_line, 1, -2)
    _line = ""
  end
  return line
end
