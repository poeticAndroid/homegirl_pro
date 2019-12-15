function _init()
  local sw, sh = view.size(view.newscreen(15, 8))
  defpal()
  text.copymode(1)

  local x, y, col = 0, 0, 0
  local w, h
  local files = fs.list()
  for i, file in ipairs(files) do
    if string.sub(file, -4) == ".gif" then
      f = text.loadfont("./" .. file)
      w, h = text.draw(string.gsub(file, "%.gif", ""), f, x, y)
      if w > (col - x) then
        col = x + w
      end
      y = y + h + 1
      if y >= sh then
        y = y - h - 1
        gfx.fgcolor(0)
        gfx.bar(x, y, 640, h)
        gfx.fgcolor(1)
        x = col
        y = 0
        w, h = text.draw(string.gsub(file, "%.gif", ""), f, x, y)
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

function defpal()
  gfx.palette(0, 5, 5, 5)
  gfx.palette(1, 15, 15, 15)
  gfx.palette(2, 0, 0, 0)
  gfx.palette(3, 10, 10, 10)
end
