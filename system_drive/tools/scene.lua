local Screen, Menu, FileRequester, Path = require("screen"), require("menu"), require("filerequester"), require("path")
local scrn
local filename, costumepath, scene, costumes, fonts
local camera, handle
local focusedactor, editing, tool
local history

function _init(args)
  scrn = Screen:new("Scene editor", 15, 8)
  scrn:attach(
    "menu",
    Menu:new(
      {
        {
          label = "File",
          menu = {
            {label = "Load..", action = reqload, hotkey = "l"},
            {label = "Save", action = save, hotkey = "s"},
            {label = "Save as..", action = reqsave},
            {label = "Quit", action = quit, hotkey = "q"}
          }
        },
        {
          label = "Tool",
          onopen = updatetoolmenu,
          menu = {
            {label = "Pan", _tool = 1, action = settool, hotkey = "p"},
            {label = "Create..", _tool = 2, action = settool, hotkey = "n"},
            {label = "Edit..", _tool = 3, action = settool, hotkey = "e"},
            {label = "Remove", _tool = 4, action = settool, hotkey = "r"},
            {label = "Move", _tool = 5, action = settool, hotkey = "m"},
            {label = "Duplicate", _tool = 6, action = settool, hotkey = "d"}
          }
        }
      }
    )
  )
  tool = 1
  scrn:autocolor()
  fonts = {}
  fonts["victoria.8b"] = text.loadfont("victoria.8b")
  loadscene(args[1] or "user:new.scene.lua")
end

function _step(t)
  scrn:step(t)
  local key = input.hotkey()
  if key == "z" then
    undo()
  end
  if key == "\x1b" then
    settool({_tool = 1})
  end
  render()
  if editing then
    local txt = input.text()
    local cur, sel = input.cursor()
    if cur == #txt and string.sub(txt, -2) == "\n\n" then
      for i, actor in ipairs(scene.actors) do
        if actor == editing then
          scene.actors[i] = fillactor(load("return { " .. txt .. "}")())
        end
      end
      editing = nil
    end
    text.copymode(17, true)
    gfx.fgcolor(scrn.darkcolor)
    local tw, th = text.draw(txt, fonts["victoria.8b"])
    gfx.bar(0, 0, tw + 8, th + 8)
    gfx.fgcolor(gfx.nearestcolor(10, 10, 10))
    text.draw(txt, fonts["victoria.8b"])
    txt = string.sub(txt, 1, cur + sel) .. "_"
    gfx.fgcolor(scrn.lightcolor)
    text.draw(txt, fonts["victoria.8b"])
    txt = string.sub(txt, 1, cur)
    gfx.fgcolor(gfx.nearestcolor(10, 10, 10))
    text.draw(txt, fonts["victoria.8b"])
  end
end

function reqload()
  if scrn.children["req"] then
    return
  end
  local req = FileRequester:new("Load scene..", {".scene.lua"}, filename .. "/../")
  req.ondone = function(self, filename)
    if filename then
      loadscene(filename)
    end
  end
  scrn:attachwindow("req", req)
end
function loadscene(_filename)
  filename = _filename
  if fs.isfile(filename) then
    scene = dofile(filename)
  else
    scene = {actors = {}}
  end
  emptywardrope()
  costumepath = Path.trailslash(Path.resolve(filename, "../../costumes"))
  for i, actor in ipairs(scene.actors) do
    fillactor(actor)
  end
  if scene.palette then
    costumes[scene.palette] = costumes[scene.palette] or image.load(costumepath .. scene.palette .. ".gif")
    scrn:usepalette(costumes[scene.palette][1])
    scrn:autocolor()
  end
  camera = vec(0, 0)
  history = {}
  saved = true
end

function reqsave()
  if scrn.children["req"] then
    return
  end
  local req = FileRequester:new("Save scene..", {".scene.lua"}, filename .. "/../")
  req.ondone = function(self, filename)
    if filename then
      savescene(filename)
    end
  end
  scrn:attachwindow("req", req)
end
function save()
  savescene(filename)
end
function savescene(_filename)
  filename = _filename or filename
  fs.write(filename, "return " .. stringifytable(scene))
  saved = true
end

function quit()
  sys.exit()
end

function updatetoolmenu(struct)
  for i, item in ipairs(struct.menu) do
    item.checked = tool == item._tool
  end
end
function settool(struct)
  tool = struct._tool
  editing = nil
end

function render()
  gfx.bgcolor(scene.bgcolor)
  gfx.cls()
  local w, h = scrn:size()
  local mx, my, mb = input.mouse()
  mx = mx - w / 2 + camera.x
  my = my - h / 2 + camera.y
  if mb == 1 then
    if not handle then
      commit()
      if tool == 1 then
        handle = vec(mx, my)
      elseif focusedactor then
        handle = vec(focusedactor.position.x - mx, focusedactor.position.y - my)
      end
      if editing == nil and (tool == 2 or tool == 3) then
        if tool == 2 then
          focusedactor =
            fillactor(
            {
              costume = "",
              role = "role",
              position = {x = mx, y = my},
              size = {x = 32, y = 32},
              anchor = {x = 16, y = 16}
            }
          )
          table.insert(scene.actors, focusedactor)
        end
        editing = focusedactor
        input.text(stringifytable(editing, ""))
        input.cursor(0)
        input.clearhistory()
        focusedactor = nil
      end
      if tool == 4 then
        removeactor(focusedactor)
      end
      if tool == 6 then
        focusedactor = load("return " .. stringifytable(focusedactor))()
        table.insert(scene.actors, focusedactor)
      end
    end
    if tool == 1 then
      camera.x = camera.x - (mx - handle.x)
      camera.y = camera.y - (my - handle.y)
      mx, my = handle.x, handle.y
    end
    if tool > 4 then
      focusedactor.position.x = mx + handle.x
      focusedactor.position.y = my + handle.y
    end
  else
    handle = nil
  end
  sys.stepinterval(-2)
  for i, actor in ipairs(scene.actors) do
    local screenpos = vec(w / 2 - camera.x + actor.position.x, h / 2 - camera.y + actor.position.y)
    if
      mb == 0 and actor.size and actor.anchor and mx >= actor.position.x - actor.anchor.x * actor.scale.x and
        my >= actor.position.y - actor.anchor.y * actor.scale.y and
        mx < actor.position.x - actor.anchor.x * actor.scale.x + actor.size.x * actor.scale.x and
        my < actor.position.y - actor.anchor.y * actor.scale.y + actor.size.y * actor.scale.y
     then
      focusedactor = actor
    end
    if actor.role == "text" then
      actor.size = actor.size or vec(text.draw(actor.text, fonts[actor.font], 1024, 1024))
      actor.anchor = actor.anchor or vec(actor.size.x / 2, actor.size.y / 2)
      text.copymode(actor.copymode or 17, true)
      text.draw(actor.text, fonts[actor.font], screenpos.x - actor.anchor.x, screenpos.y - actor.anchor.y)
    elseif actor.costume and costumes[actor.costume] then
      actor.size = actor.size or vec(image.size(costumes[actor.costume][actor.frame]))
      actor.anchor = actor.anchor or vec(actor.size.x / 2, actor.size.y / 2)
      image.draw(
        costumes[actor.costume][actor.frame],
        screenpos.x - actor.anchor.x * actor.scale.x,
        screenpos.y - actor.anchor.y * actor.scale.y,
        0,
        0,
        actor.size.x * actor.scale.x,
        actor.size.y * actor.scale.y,
        actor.size.x,
        actor.size.y
      )
    end
    if i > 1 and actor.z < scene.actors[i - 1].z then
      scene.actors[i] = scene.actors[i - 1]
      scene.actors[i - 1] = actor
      sys.stepinterval(1)
    end
  end
end

function fillactor(actor)
  if actor.costume then
    scene.palette = scene.palette or actor.costume
    costumes[actor.costume] = costumes[actor.costume] or image.load(costumepath .. actor.costume .. ".gif")
    actor.frame = actor.frame or 1
    actor.size = nil
  end
  if actor.role == "text" then
    actor.text = actor.text or "Text"
    actor.font = actor.font or "victoria.8b"
    if fonts[actor.font] == nil then
      fonts[actor.font] = text.loadfont(actor.font) or text.loadfont("victoria.8b")
    end
    actor.size = nil
  end
  actor.z = actor.z or 0
  actor.scale = actor.scale or vec(1, 1)
  actor.position = actor.position or vec(0, 0)
  return actor
end

function emptywardrope()
  if costumes then
    for k, costume in pairs(costumes) do
      for i, frame in ipairs(costume) do
        image.forget(frame)
      end
    end
  end
  costumes = {}
end

function removeactor(actor)
  for i, val in ipairs(scene.actors) do
    if val == actor then
      table.remove(scene.actors, i)
    end
  end
end

function vec(x, y)
  return {x = x or 0, y = y or x or 0}
end

function stringifytable(tbl, ind)
  ind = ind or "  "
  local out = "{"
  local sep = "\n"
  if ind == "" then
    out = ""
    sep = ""
  end
  local array = tbl[1] ~= nil
  if array then
    for i, val in ipairs(tbl) do
      out = out .. sep
      local typ = type(val)
      if (typ == "number") then
        out = out .. ind .. val
      elseif (typ == "string") then
        out = out .. ind .. string.format("%q", val)
      elseif (typ == "boolean") then
        out = out .. ind .. (val and "true" or "false")
      elseif (typ == "table") then
        out = out .. ind .. stringifytable(val, ind .. "  ")
      else
        out = out .. ind .. "nil"
      end
      sep = ",\n"
    end
  else
    for k, val in pairs(tbl) do
      out = out .. sep
      out = out .. ind .. k .. " = "
      local typ = type(val)
      if (typ == "number") then
        out = out .. val
      elseif (typ == "string") then
        out = out .. string.format("%q", val)
      elseif (typ == "boolean") then
        out = out .. (val and "true" or "false")
      elseif (typ == "table") then
        out = out .. stringifytable(val, ind .. "  ")
      else
        out = out .. "nil"
      end
      sep = ",\n"
    end
  end
  if ind == "" then
    return out .. ",\n"
  else
    return out .. "\n" .. string.sub(ind, 3) .. "}"
  end
end

function commit()
  local commit = stringifytable(scene)
  table.insert(history, commit)
  while #history > 32 do
    table.remove(history, 1)
  end
  if scene.palette then
    costumes[scene.palette] = costumes[scene.palette] or image.load(costumepath .. scene.palette .. ".gif")
    scrn:usepalette(costumes[scene.palette][1])
    scrn:autocolor()
  end
  saved = false
end
function undo()
  local commit = table.remove(history)
  if commit then
    scene = load("return " .. commit)()
  end
  if scene.palette then
    costumes[scene.palette] = costumes[scene.palette] or image.load(costumepath .. scene.palette .. ".gif")
    scrn:usepalette(costumes[scene.palette][1])
    scrn:autocolor()
  end
  saved = false
end
