function _init()
  local sw, sh = view.size(view.newscreen(15, 8))
  local f = image.load("saikyoblack.8bc.gif")[3]
  image.usepalette(f)
  gfx.palette(0, 0, 0, 0)
  gfx.palette(1, 15, 15, 15)
  gfx.palette(2, 7, 7, 7)
  gfx.palette(3, 4, 4, 4)
  text.copymode(1)

  local x, y, col = 0, 0, 0
  local w, h
  local files = fs.list()
  for i, file in ipairs(files) do
    if string.sub(file, -4) == ".gif" then
      f = text.loadfont("./" .. file)
      w, h = text.draw(file .. " sød", f, x, y)
      if w > (col - x) then
        col = x + w
      end
      y = y + h + 1
      if y >= sh then
        x = col
        y = 0
        w, h = text.draw(file .. " sød", f, x, y)
        if w > (col - x) then
          col = x + w
        end
        y = y + h + 1
      end
    end
  end
end

function _step()
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
end
