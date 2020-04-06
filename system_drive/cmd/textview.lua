local Window = require("window")
local win, txt, wrappedtxt, width, font, pos

function _init(args)
  filename = args[1]
  txt = fs.read(filename)
  win = Window:new(filename or "Text viewer", 160, 11, 320, 180 - 11)
  win.resizable = true
  win.onclose = function()
    sys.exit()
  end
  font = text.loadfont("kronos.8b") or text.loadfont("victoria.8b")
  pos = 0
  gfx.bgcolor(gfx.nearestcolor(15, 15, 15))
  gfx.fgcolor(gfx.nearestcolor(0, 0, 0))
end
function _step(t)
  win:step(t)
  local p = input.cursor()
  if p ~= 1 then
    if p < 1 then
      pos = pos - 24
    else
      pos = pos + 24
    end
    if pos < 0 then
      pos = 0
    end
    input.text("\n\n")
    input.cursor(1)
  end
  local w, h = view.size(win.mainvp)
  if w - 8 ~= width then
    wraptext(w - 8)
  end
  gfx.cls()
  w, h = text.draw(wrappedtxt, font, 4, 4 - pos)
  if pos > h - 64 then
    pos = h - 64
  end
  if input.hotkey() == "q" then
    sys.exit()
  end
end

function wraptext(maxw)
  wrappedtxt = ""
  local lines = split(txt, "\n")
  for i, line in ipairs(lines) do
    local words = split(line, " ")
    local spc = ""
    line = ""
    for j, word in ipairs(words) do
      local w, h = text.draw(line .. spc .. word, font)
      if w > maxw then
        line = line .. "\n" .. word
      else
        line = line .. spc .. word
      end
      spc = " "
    end
    wrappedtxt = wrappedtxt .. line .. "\n"
  end
  width = maxw
end

function split(inputstr, sep)
  sep = sep or "%s"
  local t = {}
  for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
    table.insert(t, field)
    if s == "" then
      return t
    end
  end
  return t
end
