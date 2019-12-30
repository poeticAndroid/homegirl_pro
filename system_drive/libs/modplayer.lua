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

  function ModPlayer:destroy()
    for i, sample in ipairs(self.samples) do
      audio.forget(sample)
    end
  end

  function ModPlayer:restart()
    self:jumpto()
  end
  function ModPlayer:jumpto(pos, div)
    self:stop()
    self.pos = pos or 1
    self.div = div or 0
    self.divend = nil
  end
  function ModPlayer:stop()
    for i = 0, 3 do
      audio.channelfreq(i, 0)
    end
  end

  function ModPlayer:step(t)
    if not self.divend then
      self.divend = t
      self.divstart = t
    end
    if self.divend < t then
      self.divstart = self.divend
      self.divend = self.divstart + self.divinterval
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
        self.chanstate[i] = self.chanstate[i] or {period = 1, volume = 1, sample = #(self.data.samples)}
        local chanstate = self.chanstate[i]
        if chanstate.periodslide then
          chanstate.period =
            math.min(math.max(chanstate.minperiod, chanstate.periodstart + chanstate.periodslide), chanstate.maxperiod)
          chanstate.prevperiodslide = chanstate.periodslide
          chanstate.periodslide = nil
        end
        if chanstate.volumeslide then
          chanstate.volume = math.min(math.max(0, chanstate.volumestart + chanstate.volumeslide), 63)
          chanstate.prevvolumeslide = chanstate.volumeslide
          chanstate.volumeslide = nil
        end
        chanstate.prevperiod = chanstate.period
        if chan.sample > 0 then
          chanstate.sample = chan.sample
          local sam = chanstate.sample
          audio.play(i - 1, self.samples[sam])
          chanstate.volume = audio.channelvolume(i - 1, self.data.samples[sam].volume)
        end
        if chan.period > 0 then
          chanstate.period = chan.period
          chanstate.semitone = chan.semitone
        end
        local fx, x, y = chan.effect.id, chan.effect.x, chan.effect.y
        local z = x * 16 + y
        if fx == 0 and z > 0 then -- Arpeggio
          print("Arpeggio")
        elseif fx == 1 or fx == 2 then -- Slide up/down
          if fx == 1 then
            z = z * -1
          end
          chanstate.periodstart = chanstate.period
          if z == 0 then
            chanstate.periodslide = chanstate.prevperiodslide
          else
            chanstate.periodslide = z * (self.ticksperdiv - 1)
          end
          chanstate.minperiod = 113
          chanstate.maxperiod = 856
        elseif fx == 3 then -- Slide to note
          chanstate.periodstart = chanstate.prevperiod
          chanstate.periodslide =
            math.max(math.abs(z * (self.ticksperdiv - 1)), math.abs(chanstate.period - chanstate.periodstart))
          if chanstate.periodstart > chanstate.period then
            chanstate.periodslide = chanstate.periodslide * -1
          end
          chanstate.minperiod = math.min(chanstate.periodstart, chanstate.period)
          chanstate.maxperiod = math.max(chanstate.periodstart, chanstate.period)
        elseif fx == 4 then -- Vibrato
          chanstate.periodstart = chanstate.period
          chanstate.minperiod = chanstate.period
          chanstate.maxperiod = chanstate.period
          chanstate.periodslide = 0
          chanstate.vibratospeed = math.pi * ((x * self.ticksperdiv) / 32)
          chanstate.vibratoamp = (y / 16) * (chanstate.period / 12)
        elseif fx == 9 then -- Set sample offset
          audio.channelhead(i - 1, (x * 4096 + y * 256) * 2)
        elseif fx == 10 then -- Volume slide
          chanstate.volumestart = chanstate.volume
          if x > 0 then
            chanstate.volumeslide = x * (self.ticksperdiv - 1)
          elseif y > 0 and chanstate.volume >= y then
            chanstate.volumeslide = -y * (self.ticksperdiv - 1)
          else
            chanstate.volumeslide = chanstate.prevvolumeslide
          end
        elseif fx == 11 then -- Position Jump
          self.pos = z + 1
          self.div = 0
        elseif fx == 12 then -- Set volume
          chanstate.volume = audio.channelvolume(i - 1, z)
        elseif fx == 13 then -- Pattern Break
          self.pos = self.pos + 1
          self.div = x * 10 + y
        elseif fx == 1400 then -- Set filter on/off
          -- This is not a real Amiga
        elseif fx == 15 then -- Set speed
          if z <= 32 then
            self.ticksperdiv = z
          else
            self.bpm = z
          end
          self.divinterval = (1000 * 60) / ((24 * self.bpm) / self.ticksperdiv)
        elseif fx + z > 0 then
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
    if not self._div then
      return
    end
    for i, chan in ipairs(self._div) do
      local chanstate = self.chanstate[i]
      local fx, x, y = chan.effect.id, chan.effect.x, chan.effect.y
      local z = x * 16 + y
      if fx == 0 and z > 0 then -- Arpeggio
      elseif fx == 1 or fx == 2 or fx == 3 then -- Slide up/down/to note
        chanstate.period =
          math.min(
          math.max(chanstate.minperiod, chanstate.periodstart + self.divpos * chanstate.periodslide),
          chanstate.maxperiod
        )
      elseif fx == 4 then -- Vibrato
        chanstate.period = chanstate.periodstart + math.sin(self.divpos * chanstate.vibratospeed) * chanstate.vibratoamp
      elseif fx == 10 then -- Volume slide
        chanstate.volume = math.min(math.max(0, chanstate.volumestart + self.divpos * chanstate.volumeslide), 63)
      end
      audio.channelvolume(i - 1, chanstate.volume)
      audio.channelfreq(i - 1, 7093789.2 / (2 * chanstate.period))
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
