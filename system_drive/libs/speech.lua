local Object, SampleEdit = require("object"), require("sampleedit")

local phones = {
  "AA",
  "AE",
  "AH",
  "AO",
  "AW",
  "AY",
  "B",
  "CH",
  "D",
  "DH",
  "EH",
  "ER",
  "EY",
  "F",
  "G",
  "HH",
  "IH",
  "IY",
  "JH",
  "K",
  "L",
  "M",
  "N",
  "NG",
  "OW",
  "OY",
  "P",
  "R",
  "S",
  "SH",
  "T",
  "TH",
  "UH",
  "UW",
  "V",
  "W",
  "Y",
  "Z",
  "ZH"
}
local loopables = {
  "AA",
  "AE",
  "AO",
  "CH",
  "DH",
  "EH",
  "ER",
  "F",
  "HH",
  "IH",
  "IY",
  "JH",
  "L",
  "M",
  "N",
  "NG",
  "R",
  "S",
  "SH",
  "TH",
  "UH",
  "UW",
  "V",
  "W",
  "Y",
  "Z",
  "ZH"
}
local snipsize = 1024

local Speech = Object:extend()
do
  Speech.samples = {}
  Speech.dictionary = {}

  function Speech:constructor(voicefile, dictfile)
    self:loadvoice(voicefile or _DRIVE .. "/libs/voice.wav")
    self:loaddictionary(dictfile or _DRIVE .. "/libs/cmudict-0.7b.txt")
  end

  function Speech:loadvoice(voicefile)
    local voice = audio.load(voicefile)
    local p = 0
    for i, v in ipairs(phones) do
      if not self.samples[v] then
        self.samples[v] = audio.new()
        audio.samplelength(self.samples[v], snipsize)
      end
      local l = audio.samplelength(self.samples[v])
      for j = 0, l - 1 do
        audio.samplevalue(self.samples[v], j, audio.samplevalue(voice, p))
        p = p + 1
      end
    end
    if not self.samples["."] then
      self.samples["."] = audio.new()
      audio.samplelength(self.samples["."], snipsize)
    end
    audio.forget(voice)
  end

  function Speech:loaddictionary(dictfile)
    local lines = split(fs.read(dictfile), "\n")
    for i, v in ipairs(lines) do
      local words = split(v)
      local word = table.remove(words, 1)
      self.dictionary[word] = words
    end
  end

  function Speech:texttophones(text)
    local words = split(string.upper(text))
    local phones = {}
    for i, v in ipairs(words) do
      local word = v
      while word and word ~= "" do
        while not self.dictionary[v] and v and v ~= "" do
          v = string.sub(v, 1, #v - 1)
        end
        if self.dictionary[v] and v ~= "" then
          for i, v in ipairs(self.dictionary[v]) do
            table.insert(phones, string.sub(v, 1, 2))
          end
          word = string.sub(word, #v + 1)
        else
          word = ""
        end
        v = word
      end
      table.insert(phones, ".")
    end
    return phones
  end

  function Speech:renderspeech(phones)
    local speech = audio.new()
    local p = 0
    for i, v in ipairs(phones) do
      if not self.samples[v] then
        v = "."
      end
      SampleEdit.copy(self.samples[v], speech)
      if v then
        local l = audio.samplelength(speech)
        if phones[i - 1] then
          SampleEdit.xfade(self.samples[phones[i - 1]], speech, .5, 0, 0, snipsize / 2, l - snipsize)
        end
        if phones[i + 1] then
          SampleEdit.xfade(self.samples[phones[i + 1]], speech, 0, .5, snipsize / 2, snipsize, l - snipsize / 2)
        end
      end
    end
    return speech
  end
end

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

return Speech
