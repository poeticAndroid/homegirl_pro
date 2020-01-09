local legalsigs = "\nM.K.\nFLT4\nFLT8\nM!K!\n4CHN\n6CHN\n8CHN\n"
local periods = {
  [1712] = 1,
  [1616] = 2,
  [1525] = 3,
  [1440] = 4,
  [1357] = 5,
  [1281] = 6,
  [1209] = 7,
  [1141] = 8,
  [1077] = 9,
  [1017] = 10,
  [961] = 11,
  [907] = 12,
  [856] = 13,
  [808] = 14,
  [762] = 15,
  [720] = 16,
  [678] = 17,
  [640] = 18,
  [604] = 19,
  [570] = 20,
  [538] = 21,
  [508] = 22,
  [480] = 23,
  [453] = 24,
  [428] = 25,
  [404] = 26,
  [381] = 27,
  [360] = 28,
  [339] = 29,
  [320] = 30,
  [302] = 31,
  [285] = 32,
  [269] = 33,
  [254] = 34,
  [240] = 35,
  [226] = 36,
  [214] = 37,
  [202] = 38,
  [190] = 39,
  [180] = 40,
  [170] = 41,
  [160] = 42,
  [151] = 43,
  [143] = 44,
  [135] = 45,
  [127] = 46,
  [120] = 47,
  [113] = 48,
  [107] = 49,
  [101] = 50,
  [95] = 51,
  [90] = 52,
  [85] = 53,
  [80] = 54,
  [76] = 55,
  [71] = 56,
  [67] = 57,
  [64] = 58,
  [60] = 59,
  [57] = 60
}

function parse(moddata)
  local sig = string.unpack("c4", moddata, 1081)
  local samplecount = 15
  if string.find(legalsigs, "\n" .. sig .. "\n") then
    samplecount = 31
  end
  local mod, pos = {}, 1
  mod.title = string.unpack("z", string.unpack("c20", moddata, pos), 1)
  pos = pos + 20
  mod.samples = {}
  for i = 1, samplecount do
    local sample = {}
    sample.name = string.unpack("z", string.unpack("c22", moddata, pos), 1)
    pos = pos + 22
    sample.length, pos = string.unpack(">I2", moddata, pos)
    sample.length = sample.length * 2
    sample.finetune, pos = string.unpack(">I1", moddata, pos)
    if sample.finetune > 7 then
      sample.finetune = sample.finetune - 16
    end
    sample.volume, pos = string.unpack(">I1", moddata, pos)
    sample.repeatstart, pos = string.unpack(">I2", moddata, pos)
    sample.repeatlength, pos = string.unpack(">I2", moddata, pos)
    if samplecount > 15 then
      sample.repeatstart = sample.repeatstart * 2
      sample.repeatlength = sample.repeatlength * 2
    end
    table.insert(mod.samples, sample)
  end
  mod.songlength, pos = string.unpack(">I1", moddata, pos)
  mod.restart, pos = string.unpack(">I1", moddata, pos)
  mod.restart = mod.restart + 1
  mod.patterntable = {}
  local lastpattern = 0
  for i = 1, 128 do
    local patnum = 0
    patnum, pos = string.unpack(">I1", moddata, pos)
    patnum = patnum + 1
    if patnum > lastpattern then
      lastpattern = patnum
    end
    table.insert(mod.patterntable, patnum)
  end
  if samplecount > 15 then
    mod.sig, pos = string.unpack("c4", moddata, pos)
  end
  mod.patterns = {}
  for i = 1, lastpattern do
    local pattern = {}
    for div = 1, 64 do
      local division = {}
      for chan = 1, 4 do
        local channel = {}
        local a, b, c, d
        a, b, c, d, pos = string.unpack("I1I1I1I1", moddata, pos)
        channel.sample = (a & 240) + math.floor(c / 16)
        channel.period = (a & 15) * 256 + b
        channel.fx = (c & 15) * 256 + d
        channel.semitone = periodtosemitone(channel.period)
        channel.effect = {}
        channel.effect.id = math.floor(channel.fx / 256) % 16
        channel.effect.x = math.floor(channel.fx / 16) % 16
        channel.effect.y = math.floor(channel.fx / 1) % 16
        if channel.effect.id == 14 then
          channel.effect.id = 1400 + channel.effect.x
          channel.effect.x = channel.effect.y
        end
        table.insert(division, channel)
      end
      table.insert(pattern, division)
    end
    table.insert(mod.patterns, pattern)
  end
  for i, sample in ipairs(mod.samples) do
    sample.data, pos = string.unpack("c" .. sample.length, moddata, pos)
  end
  return mod
end

function periodtosemitone(period)
  local dev = 0
  while dev < 4096 do
    if periods[period - dev] then
      return periods[period - dev]
    end
    if periods[period + dev] then
      return periods[period + dev]
    end
    dev = dev + 1
  end
end

return parse
