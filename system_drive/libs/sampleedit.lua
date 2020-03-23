local SampleEdit = {}
SampleEdit = {
  getvalue = function(sampl, pos)
    local fp, cp = math.floor(pos), math.ceil(pos)
    local sub = pos - fp
    if sub == 0 then
      return audio.samplevalue(sampl, pos)
    end
    local fv, cv = audio.samplevalue(sampl, fp), audio.samplevalue(sampl, cp)
    return fv + sub * (cv - fv)
  end,
  copy = function(src, dest, srcpos, srclen, destpos, destlen)
    dest = dest or audio.new()
    srcpos = math.min(math.max(0, srcpos or 0), audio.samplelength(src))
    srclen = math.min(math.max(0, srclen or audio.samplelength(src)), audio.samplelength(src) - srcpos)
    destpos = math.max(0, destpos or audio.samplelength(dest))
    destlen = math.max(0, destlen or srclen)
    audio.samplelength(dest, math.max(audio.samplelength(dest), destpos + destlen))
    for i = 0, destlen - 1 do
      audio.samplevalue(dest, destpos + i, SampleEdit.getvalue(src, srcpos + (i / destlen) * srclen))
    end
    return dest
  end,
  fade = function(sampl, startval, endval, pos, length)
    startval = startval or 1
    endval = endval or startval
    pos = math.min(math.max(0, pos or 0), audio.samplelength(sampl))
    length = math.min(math.max(0, length or audio.samplelength(sampl)), audio.samplelength(sampl) - pos)
    for i = 0, length - 1 do
      local val = audio.samplevalue(sampl, pos + i)
      local param = startval + (i / length) * (endval - startval)
      audio.samplevalue(sampl, pos + i, val * param)
    end
    return sampl
  end,
  xfade = function(src, dest, startval, endval, srcpos, srclen, destpos)
    dest = dest or audio.new()
    startval = startval or 1
    endval = endval or startval
    srcpos = math.min(math.max(0, srcpos or 0), audio.samplelength(src))
    srclen = math.min(math.max(0, srclen or audio.samplelength(src)), audio.samplelength(src) - srcpos)
    destpos = math.max(0, destpos or audio.samplelength(dest))
    audio.samplelength(dest, math.max(audio.samplelength(dest), destpos + srclen))
    for i = 0, srclen - 1 do
      local dval = audio.samplevalue(dest, destpos + i)
      local sval = audio.samplevalue(src, srcpos + i)
      local param = startval + (i / srclen) * (endval - startval)
      audio.samplevalue(dest, destpos + i, dval + param * (sval - dval))
    end
    return dest
  end,
  normalize = function(sampl, maxval, pos, length)
    maxval = maxval or 127
    pos = math.min(math.max(0, pos or 0), audio.samplelength(sampl))
    length = math.min(math.max(0, length or audio.samplelength(sampl)), audio.samplelength(sampl) - pos)
    local _maxval = 0
    for i = 0, length - 1 do
      local val = math.abs(audio.samplevalue(sampl, pos + i))
      if _maxval < val then
        _maxval = val
      end
    end
    return SampleEdit.fade(sampl, maxval / _maxval, nil, pos, length)
  end,
  straightpitch = function(sampl, dest, samsperhz, pos, length)
    dest = dest or audio.new()
    samsperhz = samsperhz or 32
    pos = math.min(math.max(0, pos or 0), audio.samplelength(sampl))
    length = math.min(math.max(0, length or audio.samplelength(sampl)), audio.samplelength(sampl) - pos)
    local destpos = audio.samplelength(dest)
    local maxamp = 127
    local lasthit = 0
    local lasthz = 0
    for i = 0, length - 1 do
      local val = audio.samplevalue(sampl, pos + i)
      if maxamp < math.abs(val) then
        maxamp = math.abs(val)
      elseif math.abs(val) < maxamp / 2 then
        if maxamp > 3 then
          maxamp = maxamp - 1
        end
      elseif val > maxamp / 2 then
        lasthit = 1
      elseif val < -maxamp / 2 then
        if lasthit > 0 then
          SampleEdit.copy(sampl, dest, lasthz, i - lasthz, destpos, samsperhz)
          lasthz = i
          destpos = destpos + samsperhz
        end
        lasthit = -1
      end
    end
    return dest
  end
}
return SampleEdit
