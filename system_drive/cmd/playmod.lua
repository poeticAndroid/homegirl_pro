local ModPlayer = require("modplayer")
local mod, pos = 0, 0

function _init(args)
  mod = ModPlayer:new(args[1])
  for i, sample in ipairs(mod.data.samples) do
    if sample.name ~= "" and string.sub(sample.name, 1, 1) ~= "#" then
      print(sample.name)
    end
  end
  print(mod.data.sig)
  print("Title: " .. mod.data.title .. "\n")
  for i, sample in ipairs(mod.data.samples) do
    if string.sub(sample.name, 1, 1) == "#" then
      print(sample.name)
    end
  end
  mod.data.restart = 1
  sys.stepinterval(0)
end

function _step(t)
  mod:step(t)
  if pos > mod.pos then
    mod:stop()
    print("The end!")
    return sys.exit()
  end
  pos = mod.pos
end
