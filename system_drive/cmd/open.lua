local Window, Menu, Icon, UI, path = require("window"), require("menu"), require("icon"), require("ui"), require("path")
local win, openfile, task, ended, showall
local log, logx, logy, backimg = "", 0, 0, image.new(8, 8, 3)

function _init(args)
  openfile = path.notrailslash(path.resolve(fs.cd(), table.remove(args, 1)))
  if fs.isdir(openfile) then
    openfile = path.trailslash(openfile)
    createdirwindow()
  else
    sys.stepinterval(64)
    fs.cd(path.resolve(openfile .. "/.."))
    local ext = ""
    if string.find(openfile, "%.") then
      ext = string.lower(string.sub(openfile, 1 - string.find(string.reverse(openfile), "%.")))
    end
    if ext == "lua" then
      task = sys.startchild(openfile, args)
    elseif ext == "gif" then
      task = sys.startchild(_DRIVE .. "cmd/show.lua", {openfile})
    elseif ext == "wav" then
      task = sys.startchild(_DRIVE .. "cmd/play.lua", {openfile})
    else
      task = sys.startchild(_DRIVE .. "cmd/edit.lua", {openfile})
    end
  end
end

function createwindow()
  if win then
    return
  end
  local sw, sh = view.size(nil)
  local x, y = 64, 1
  local drives = fs.drives()
  local segs = path.split(openfile)
  table.sort(drives)
  while #drives > 0 and string.lower(drives[1] .. ":") ~= string.lower(segs[1]) do
    if x >= 10 then
      x = x - 10
    end
    y = y + 20
    table.remove(drives, 1)
  end
  x = x + #segs * 32
  y = y + #segs * 10
  win = Window:new(openfile, x, y, sw / 2, sh / 2)
  win.resizable = true
  win.onclose = function()
    sys.exit()
  end
  view.active(win.mainvp)
end

function createdirwindow()
  createwindow()
  win:icon(_DRIVE .. "icons/dir.gif")
  view.size(win._resbtn, 11, 11)
  win:step(42)
  showall = not listhasicons(fs.list(openfile))
  win:attach(
    "menu",
    Menu:new(
      {
        {
          label = "Directory",
          menu = {
            {label = "Refresh", hotkey = "r", action = refresh},
            {
              label = "Show all files",
              hotkey = "i",
              checked = showall,
              action = function(self)
                showall = not showall
                self.checked = showall
                refresh()
              end
            }
          }
        },
        {
          label = "File",
          menu = {
            {label = "Open", hotkey = "o", action = openselected},
            {label = "Edit", hotkey = "e", action = editselected},
            {label = "Info", action = infoselected}
          }
        }
      }
    )
  )
  local board = win:attach("items", UI.Scrollbox:new()):attach("items", Icon.Board:new())
  board.ondrop = function(self, drop)
    if not string.find(drop, "%:") then
      return nil
    end
    if fs.rename(drop, openfile .. path.basename(drop)) then
      if fs.isfile(path.notrailslash(drop) .. ".gif") then
        fs.rename(path.notrailslash(drop) .. ".gif", openfile .. path.basename(drop) .. ".gif")
      end
    else
      sys.exec(_DRIVE .. "cmd/open.lua", {_DRIVE .. "cmd/copy.lua", drop, openfile})
      if fs.isfile(path.notrailslash(drop) .. ".gif") then
        fs.write(openfile .. path.basename(drop) .. ".gif", fs.read(path.notrailslash(drop) .. ".gif"))
      end
    end
    return Icon:new(path.basename(drop), iconfor(drop))
  end
  refresh()
  sys.stepinterval(-1)
end

function _step(t)
  if task then
    if win then
      win:step(t)
      sys.writetochild(task, string.sub(input.text(), 1, 1))
      log = log .. string.sub(input.text(), 1, 1)
      input.text("")
    end
    log = log .. sys.readfromchild(task) .. sys.errorfromchild(task)
    if log ~= "" or win then
      createwindow()
      local ww, wh = view.size(win.mainvp)
      local iw, ih = image.size(backimg)
      local tl = firstline(log)
      local tw, th = text.draw(tl, win.font)
      gfx.cls()
      image.draw(backimg, 0, wh - ih - th, 0, 0, iw, ih)
      tw, th = text.draw(tl, win.font, 0, wh - th)
      if tw > ww then
        while tw > ww do
          tl = string.sub(tl, 1, #tl - 1)
          tw, th = text.draw(tl, win.font, 0, wh - th)
        end
        if ww ~= iw or wh ~= ih then
          image.forget(backimg)
          backimg = image.new(ww, wh, 3)
        end
        image.copy(backimg, 0, 0, 0, 0, ww, wh)
        log = string.sub(log, #tl + 1)
      elseif tl ~= log then
        if ww ~= iw or wh ~= ih then
          image.forget(backimg)
          backimg = image.new(ww, wh, 3)
        end
        image.copy(backimg, 0, 0, 0, 0, ww, wh)
        log = string.sub(log, #tl + 2)
      end
    end
    if not sys.childrunning(task) then
      if win then
        if not ended then
          if sys.childexitcode(task) == 0 then
            log = log .. "\n[Program ended successfully]"
          else
            log = log .. "\n[Program ended with error code " .. sys.childexitcode(task) .. "]"
          end
        end
      else
        sys.exit()
      end
      ended = true
    end
  elseif win then
    win:step(t)
    view.active(win.mainvp)
    sys.stepinterval(sys.stepinterval() * -1)
  end
end

function refresh()
  local board = win.children["items"].children["items"]
  local items = fs.list(openfile)
  local iconsonly = not showall
  table.sort(items)
  for i, item in ipairs(items) do
    local filename = openfile .. item
    local show = not iconsonly
    if fs.isfile(path.notrailslash(filename) .. ".gif") then
      show = true
    end
    if string.sub(filename, -11) == ":_drive.gif" then
      show = false
    end
    if
      string.sub(filename, -4) == ".gif" and
        (fs.isfile(string.sub(filename, 1, -5)) or fs.isdir(string.sub(filename, 1, -5)))
     then
      show = false
    end
    if show then
      items[filename] = true
      if not board.children[filename] then
        board:attach(filename, Icon:new(path.notrailslash(item), iconfor(filename))).onopen = onopen
      end
    end
  end
  for item, child in pairs(board.children) do
    if not items[item] then
      board:destroychild(item)
    end
  end
end

function openselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  for i, name in ipairs(selected) do
    sys.exec(_DRIVE .. "cmd/open.lua", {name})
  end
end
function editselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  for i, name in ipairs(selected) do
    sys.exec(_DRIVE .. "cmd/edit.lua", {name})
  end
end
function infoselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  for i, name in ipairs(selected) do
    sys.exec(_DRIVE .. "cmd/open.lua", {_DRIVE .. "cmd/fileinfo.lua", name})
  end
end

function onopen(icon)
  local filename = icon.drop
  sys.exec(_DRIVE .. "cmd/open.lua", {filename})
end

function listhasicons(list)
  local seen = {}
  for i, item in ipairs(list) do
    seen[path.notrailslash(item)] = true
    if seen[path.notrailslash(item) .. ".gif"] then
      return true
    end
    if string.sub(item, -4) == ".gif" then
      if seen[string.sub(item, 1, -5)] then
        return true
      end
    end
  end
  return false
end

function iconfor(filename)
  if string.sub(filename, -1) == ":" then
    if fs.isfile(filename .. "_drive.gif") then
      return filename .. "_drive.gif"
    else
      return _DRIVE .. "icons/drive.gif"
    end
  elseif fs.isfile(path.notrailslash(filename) .. ".gif") then
    return path.notrailslash(filename) .. ".gif"
  elseif fs.isdir(filename) then
    return _DRIVE .. "icons/dir.gif"
  else
    local ext = "file"
    if string.find(filename, "%.") then
      ext = string.lower(string.sub(filename, 1 - string.find(string.reverse(filename), "%.")))
    end
    if fs.isfile(_DRIVE .. "icons/" .. ext .. ".gif") then
      return _DRIVE .. "icons/" .. ext .. ".gif"
    end
  end
  return _DRIVE .. "icons/file.gif"
end

function firstline(txt)
  local nl = string.find(txt, "\n")
  if nl then
    return string.sub(txt, 1, nl - 1)
  else
    return txt
  end
end
