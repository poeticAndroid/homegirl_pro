local ModPlayer = require("modplayer")
local mod, pos, div, postime = 0, 0, 0

function _init(args)
  mod = ModPlayer:new(args[1])
  print(mod.data.sig)
  for i, sample in ipairs(mod.data.samples) do
    if sample.name ~= "" and string.sub(sample.name, 1, 1) ~= "#" then
      print(sample.name)
    end
  end
  print("\nTitle: " .. mod.data.title .. "\n")
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
  if not postime then
    postime = t
  end
  if pos > mod.pos or (t - postime) > (1000 * 60) then
    mod:stop()
    print("The end!")
    return sys.exit()
  end
  -- if pos ~= mod.pos then
  --   print("Table " .. (mod.pos - 1))
  -- end
  -- if mod._div and div ~= mod.div then
  --   print(
  --     string.format(
  --       "%02X %03X%02X%03X %03X%02X%03X %03X%02X%03X %03X%02X%03X",
  --       mod.div - 1,
  --       mod._div[1].period,
  --       mod._div[1].sample,
  --       mod._div[1].fx,
  --       mod._div[2].period,
  --       mod._div[2].sample,
  --       mod._div[2].fx,
  --       mod._div[3].period,
  --       mod._div[3].sample,
  --       mod._div[3].fx,
  --       mod._div[4].period,
  --       mod._div[4].sample,
  --       mod._div[4].fx
  --     )
  --   )
  -- end
  if pos ~= mod.pos then
    postime = t
  end
  pos = mod.pos
  div = mod.div
end
