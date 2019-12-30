local Object, MOD = require("object"), require("mod")
local unknownfx = {max = 0}

local ModPlayer = Object:extend()
do
  function ModPlayer:constructor(filename)
    self.data = MOD(fs.read(filename))
    self.samples = {}
    for i, sample in ipairs(self.data.samples) do
      local sam = audio.new()
      audio.samplelength(sam, sample.length)
      for i = 1, sample.length do
        audio.samplevalue(sam, i - 1, string.unpack("i1", sample.data, i))
      end
      if sample.repeatlength > 2 then
        audio.sampleloop(sam, sample.repeatstart, sample.repeatstart + sample.repeatlength)
      end
      table.insert(self.samples, sam)
    end
    self.ticksperdiv = 6
    self.bpm = 125
    self.divinterval = (1000 * 60) / ((24 * self.bpm) / self.ticksperdiv)
    self.chanstate = {}
    self:jumpto()
    self:_semitonetofreq(48)
  end

  function ModPlayer:jumpto(pos, div)
    self.pos = pos or 1
    self.div = div or 0
    self.divend = nil
  end

  function ModPlayer:step(t)
    if not self.divend then
      self.divend = t
      self.divstart = t
      self.nexttick = t
    end
    if self.divend < t then
      self.divstart = self.divend
      self.divend = self.divstart + self.divinterval
      self.nexttick = self.divstart + (self.divinterval / self.ticksperdiv)
      self.div = self.div + 1
      if self.div > 64 then
        self.div = 1
        self.pos = self.pos + 1
      end
      if self.pos > self.data.songlength then
        self.pos = self.data.restart
      end
      -- print("pos: " .. self.pos .. "\tdiv: " .. self.div)
      self._div = self.data.patterns[self.data.patterntable[self.pos]][self.div]
      for i, chan in ipairs(self._div) do
        self.chanstate[i] = self.chanstate[i] or {}
        local chanstate = self.chanstate[i]
        if chan.period > 0 then
          chanstate.period = chan.period
          chanstate.semitone = chan.semitone
        end
        local sam = chan.sample
        if self.samples[sam] then
          audio.play(i - 1, self.samples[sam])
          audio.channelfreq(i - 1, 7093789.2 / (2 * chanstate.period))
          chanstate.volume = audio.channelvolume(i - 1, self.data.samples[sam].volume)
        end
        local fx, x, y = chan.effect.id, chan.effect.x, chan.effect.y
        local z = x * 16 + y
        if fx == 0 then -- Arpeggio
        elseif fx == 9 then -- Set sample offset
          audio.channelhead(i - 1, (x * 4096 + y * 256) * 2)
        elseif fx == 10 then -- Volume slide
          chanstate.volumestart = chanstate.volume
          if x > 0 then
            chanstate.volumeslide = x * (self.ticksperdiv - 1)
          elseif y > 0 and chanstate.volume >= y then
            chanstate.volumeslide = -y * (self.ticksperdiv - 1)
          end
        elseif fx == 11 then -- Position Jump
          self.pos = z + 1
          self.div = 0
        elseif fx == 12 then -- Set volume
          chanstate.volume = audio.channelvolume(i - 1, z)
        elseif fx == 13 then -- Pattern Break
          self.pos = self.pos + 1
          self.div = x * 10 + y
        elseif fx == 15 then -- Set speed
          if z <= 32 then
            self.ticksperdiv = z
          else
            self.bpm = z
          end
          self.divinterval = (1000 * 60) / ((24 * self.bpm) / self.ticksperdiv)
        else
          if not unknownfx[fx] then
            print("unknown fx " .. fx .. " " .. x .. " " .. y)
          end
          unknownfx[fx] = unknownfx[fx] or 0
          unknownfx[fx] = unknownfx[fx] + 1
          if unknownfx[fx] > unknownfx.max then
            unknownfx.max = unknownfx[fx]
            if unknownfx.pop ~= fx then
              unknownfx.pop = fx
              print("popular fx " .. fx)
            end
          end
        end
      end
      self.divend = self.divstart + self.divinterval
      if self.divend < t then
        self.divend = t
      end
    end
    self.divpos = (t - self.divstart) / self.divinterval
    if self.nexttick < t then
      self.nexttick = self.nexttick + (self.divinterval / self.ticksperdiv)
    end
    if not self._div then
      return
    end
    for i, chan in ipairs(self._div) do
      local chanstate = self.chanstate[i]
      local fx, x, y = chan.effect.id, chan.effect.x, chan.effect.y
      local z = x * 16 + y
      if fx == 4 then -- Vibrato
      elseif fx == 10 then -- Volume slide
        chanstate.volume =
          audio.channelvolume(
          i - 1,
          math.min(math.max(0, chanstate.volumestart + self.divpos * chanstate.volumeslide), 63)
        )
      end
    end
  end

  function ModPlayer:_semitonetofreq(semitone)
    local f0 = 1955.4716072983
    local fa = math.pow(2, 1 / 12)
    local freq = f0 * math.pow(fa, semitone)
    if freq > 32000 then
      print("!! " .. semitone .. " -> " .. freq)
    end
    return freq
  end
end

return ModPlayer
