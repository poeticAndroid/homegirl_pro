local Window, Menu, Icon, Dia, UI, path =
  require("window"),
  require("menu"),
  require("icon"),
  require("dialog"),
  require("ui"),
  require("path")
local win, openfile, task, ended, showall
local _log, log, logx, logy, backimg, logvp = "", "", 0, 0, image.new(8, 8, 3)

function _init(args)
  openfile = path.notrailslash(path.resolve(fs.cd(), table.remove(args, 1)))
  if fs.isdir(openfile) then
    openfile = path.trailslash(openfile)
    fs.cd(openfile)
    createdirwindow()
  else
    sys.stepinterval(1)
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
    elseif ext == "mod" then
      task = sys.startchild(_DRIVE .. "cmd/playmod.lua", {openfile})
    else
      task = sys.startchild(_DRIVE .. "cmd/textview.lua", {openfile})
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
            {
              label = "New",
              menu = {
                {label = "File..", hotkey = "f", action = newfile},
                {label = "Directory..", hotkey = "d", action = newdir}
              }
            },
            {label = "Refresh", hotkey = "r", action = refresh},
            {label = "Open shell here", hotkey = "s", action = shellhere},
            {
              label = "Show all files",
              hotkey = "i",
              checked = showall,
              action = function(self)
                showall = not showall
                self.checked = showall
                refresh()
              end
            },
            {label = "Close", hotkey = "q", action = win.onclose}
          }
        },
        {
          label = "Item(s)",
          menu = {
            {label = "Open", hotkey = "o", action = openselected},
            {label = "Edit", hotkey = "e", action = editselected},
            {label = "Rename..", hotkey = "n", action = renameselected},
            {label = "Duplicate", hotkey = "c", action = duplicateselected},
            {label = "Delete..", action = deleteselected},
            {label = "Info", action = infoselected},
            {label = "Kill..", action = killselected}
          }
        }
      }
    )
  )
  local board = win:attach("items", UI.Scrollbox:new()):attach("items", Icon.Board:new())
  if fs.isfile(openfile .. "_background.gif") then
    board.backgroundimage = image.load(openfile .. "_background.gif")[1]
  end
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
      local sw, sh = view.size(false)
      local ww, wh = view.size(win.mainvp)
      view.position(logvp, 0, wh - sh)
      sys.writetochild(task, string.sub(input.text(), 1, 1))
      log = log .. string.sub(input.text(), 1, 1)
      input.text("")
      if input.hotkey() == "c" then
        sys.killchild(task)
      end
      if input.hotkey() == "q" then
        win:onclose()
      end
    end
    log = log .. sys.readfromchild(task) .. sys.errorfromchild(task)
    local stpint = sys.stepinterval()
    if not ended and stpint < 128 then
      sys.stepinterval(stpint + 1)
    end
    if ended and stpint >= 0 then
      sys.stepinterval(stpint - 1)
    end
    while log ~= _log do
      _log = log
      sys.stepinterval(1)
      local sw, sh = view.size(false)
      if not win then
        createwindow()
        logvp = view.new(win.mainvp, 0, 0, sw, sh)
        view.active(logvp)
      end
      local ww, wh = view.size(win.mainvp)
      local iw, ih = image.size(backimg)
      local tl = firstline(log)
      local tw, th = text.draw(tl, win.font)
      gfx.cls()
      image.draw(backimg, 0, sh - ih - th, 0, 0, iw, ih)
      tw, th = text.draw(tl, win.font, 0, sh)
      if tw > ww then
        while tw > ww do
          tl = string.sub(tl, 1, #tl - 1)
          tw, th = text.draw(tl, win.font, 0, sh)
        end
        tw, th = text.draw(tl, win.font, 0, sh - th)
        if sw ~= iw or sh ~= ih then
          image.forget(backimg)
          backimg = image.new(sw, sh, 3)
        end
        image.copy(backimg, 0, 0, 0, 0, sw, sh)
        log = string.sub(log, #tl + 1)
      elseif tl ~= log then
        tw, th = text.draw(tl, win.font, 0, sh - th)
        if sw ~= iw or sh ~= ih then
          image.forget(backimg)
          backimg = image.new(sw, sh, 3)
        end
        image.copy(backimg, 0, 0, 0, 0, sw, sh)
        log = string.sub(log, #tl + 2)
      else
        tw, th = text.draw(tl, win.font, 0, sh - th)
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
    if string.sub(filename, -11) == ":_drive.gif" or item == "_background.gif" then
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

function newfile()
  local prompt = win:attach("dia", Dia.Prompt:new("New file..", "What would you like to name your file?"))
  prompt.ondone = function(self, name)
    if name then
      fs.write(name, "")
      if not showall then
        fs.write(name .. ".gif", fs.read(iconfor(name)))
      end
    end
    refresh()
  end
end
function newdir()
  local prompt = win:attach("dia", Dia.Prompt:new("New directory..", "What would you like to name your directory?"))
  prompt.ondone = function(self, name)
    if name then
      fs.mkdir(name)
      if not showall then
        fs.write(name .. ".gif", fs.read(iconfor(name)))
      end
    end
    refresh()
  end
end

function shellhere()
  sys.exec(_DRIVE .. "tools/shell.lua", {}, openfile)
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
    local ext = ""
    if string.find(name, "%.") then
      ext = string.lower(string.sub(name, 1 - string.find(string.reverse(name), "%.")))
    end
    if ext == "gif" then
      sys.exec(_DRIVE .. "tools/paint.lua", {name})
    else
      sys.exec(_DRIVE .. "tools/edit.lua", {name})
    end
  end
end
function renameselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  if #selected > 0 then
    name = path.notrailslash(selected[1])
    local prompt =
      win:attach(
      "dia",
      Dia.Prompt:new("Rename item..", "What would you like to rename the item to?", path.basename(name))
    )
    prompt.ondone = function(self, newname)
      if newname then
        fs.rename(name, newname)
        fs.rename(name .. ".gif", newname .. ".gif")
      end
      refresh()
    end
  end
end
function infoselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  for i, name in ipairs(selected) do
    sys.exec(_DRIVE .. "cmd/open.lua", {_DRIVE .. "cmd/fileinfo.lua", name})
  end
end
function duplicateselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  for i, name in ipairs(selected) do
    name = path.notrailslash(name)
    sys.exec(_DRIVE .. "cmd/open.lua", {_DRIVE .. "cmd/copy.lua", name, name .. "_copy"})
    if fs.isfile(name .. ".gif") then
      fs.write(name .. "_copy.gif", fs.read(name .. ".gif"))
    end
    board:attach(name .. "_copy", Icon:new(path.basename(name .. "_copy"), iconfor(name))).onopen = onopen
  end
end
function deleteselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  local confirm =
    win:attach(
    "dia",
    Dia.Confirm:new("Delete item(s)?", "Do you really wish to delete\nthe " .. (#selected) .. " selected item(s)?")
  )
  confirm.ondone = function(self, yes)
    if yes then
      for i, name in ipairs(selected) do
        name = path.notrailslash(name)
        fs.delete(name)
        fs.delete(name .. ".gif")
      end
    end
    refresh()
  end
end
function killselected()
  local board = win.children["items"].children["items"]
  local selected = board:getselected()
  local confirm =
    win:attach(
    "dia",
    Dia.Confirm:new(
      "Kill program(s)?",
      "Do you really wish to kill all running\ninstances of the " .. (#selected) .. " selected program(s)?"
    )
  )
  confirm.ondone = function(self, yes)
    if yes then
      local kills = 0
      for i, name in ipairs(selected) do
        kills = kills + sys.killall(name)
      end
      win:attach("dia", Dia.Alert:new("Program(s) killed", "Number of instances killed: " .. kills))
    end
    refresh()
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
