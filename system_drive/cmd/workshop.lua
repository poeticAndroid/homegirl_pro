local Screen, Icon, Menu, Dia, UI, path, sysver =
  require("screen"),
  require("icon"),
  require("menu"),
  require("dialog"),
  require("ui"),
  require("path"),
  require("sysver")
local scrn, desktop

function _init()
  scrn = Screen:new((sys.env("ENGINE") or "System") .. " Workshop", 11, 3)
  scrn:palette(0, 10, 11, 12)
  scrn:palette(1, 0, 0, 0)
  scrn:palette(2, 15, 15, 15)
  scrn:palette(3, 5, 10, 15)
  scrn:palette(4, 10, 5, 5)
  scrn:palette(5, 5, 10, 5)
  scrn:palette(6, 5, 7, 10)
  scrn:palette(7, 10, 8, 5)
  scrn:colors(2, 1)

  desktop = scrn:attach("desktop", Icon.Board:new())
  if fs.isfile("user:wallpaper.gif") then
    desktop.backgroundimage = image.load("user:wallpaper.gif")[1]
  else
    desktop.backgroundimage = image.load(_DRIVE .. "stuff/homegirl_wallpaper.gif")[1]
  end

  scrn:attach(
    "menu",
    Menu:new(
      {
        {
          label = "Desktop",
          menu = {
            {
              label = "Clean up",
              hotkey = "r",
              action = function()
                desktop:tidy()
              end
            },
            {
              label = "About..",
              action = about
            }
          }
        },
        {
          label = "Drive(s)",
          menu = {
            {label = "Mount remote..", action = mountremote},
            {label = "Unmount..", action = unmountselected}
          }
        }
      }
    )
  )

  view.attribute(scrn.rootvp, "hide-enabled", "true")
  sys.stepinterval(-1)
end

function _step(t)
  view.active(scrn.rootvp)
  scrn:step(t)
  local seen = {}
  local drives = fs.drives()
  table.sort(drives)
  for i, drive in ipairs(drives) do
    seen[drive .. ":"] = true
    if not desktop.children[drive .. ":"] then
      desktop:attach(drive .. ":", Icon:new(drive, iconfor(drive .. ":"))).onopen = onopen
    end
  end

  local views = view.children(scrn.rootvp)
  table.sort(views)
  for i, vp in ipairs(views) do
    local title = view.attribute(vp, "title")
    local iconname = view.attribute(vp, "icon")
    local hidden = not view.visible(vp)
    if hidden and title then
      seen["vp" .. vp] = true
    end
    if seen["vp" .. vp] then
      if not desktop.children["vp" .. vp] then
        if not iconname or iconname == "" then
          iconname = iconfor(view.owner(vp))
        end
        desktop:attach("vp" .. vp, Icon:new(title, iconname)).onopen = unhide
      else
        desktop.children["vp" .. vp].label = title
      end
    end
  end

  for name, child in pairs(desktop.children) do
    if not seen[name] then
      desktop:destroychild(name)
    end
  end
  sys.stepinterval(sys.stepinterval() * -1)
end

function onopen(icon)
  local filename = icon.drop
  if fs.isdir(filename) then
    sys.exec(_DRIVE .. "cmd/open.lua", {filename})
  end
end

function unhide(icon)
  local vp = tonumber(string.sub(icon.drop, 3))
  view.visible(vp, true)
  view.zindex(vp, -1)
  view.focused(vp, true)
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

function about()
  scrn:attach(
    "dia",
    Dia.Alert:new(
      "About Workshop",
      "Workshop " ..
        sysver ..
          " by poeticAndroid\n\n Running on " ..
            (sys.env("ENGINE") or "<Unknown system>") .. " " .. (sys.env("ENGINE_VERSION") or "")
    )
  )
end

function filterdrives(tbl)
  local out = {}
  for i, name in ipairs(tbl) do
    if string.find(name, "%:") then
      table.insert(out, name)
    end
  end
  return out
end

function unmountselected()
  local selected = filterdrives(desktop:getselected())
  local confirm =
    scrn:attach(
    "dia",
    Dia.Confirm:new("Unmount drives(s)?", "Do you really wish to unmount\nthe " .. (#selected) .. " selected drive(s)?")
  )
  confirm.ondone = function(self, yes)
    if yes then
      for i, name in ipairs(selected) do
        if not fs.unmount(name) then
          confirm =
            scrn:attach(
            "dia",
            Dia.Confirm:new("Force unmount drives(s)?", name .. " drive seems to be in use.\nUnmount it by force?")
          )
          confirm.ondone = function(self, yes)
            if yes then
              fs.unmount(name, true)
            end
          end
        end
      end
    end
  end
end

function mountremote()
  local mountdia =
    scrn:attach(
    "dia",
    Dia.Prompt:new("Mount remote drive", "Please enter name and URL of\nthe drive you wish to mount:", "http://")
  )
  -- local urlinp = mountdia:attach("urlinp", UI.TextInput:new("http://"))
  local driveinp = mountdia:attach("driveinp", UI.TextInput:new("net:"))
  mountdia.ondone = function(self, url)
    if url and driveinp.content ~= "" then
      fs.mount(driveinp.content, url)
    end
  end
end
