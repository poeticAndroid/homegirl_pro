local Widget, Dia = require("widget"), require("dialog")
local root, knowns

local SYMS = {
  "mpm",
  "mld",
  "mrd",
  "uod",
  "mms",
  "mop",
  "rod",
  "wod",
  "rev",
  "wev",
  "rec"
}
local PERM = {
  mpm = 1,
  mld = 2,
  mrd = 4,
  uod = 8,
  mms = 16,
  mop = 32,
  rod = 256,
  wod = 512,
  rev = 1024,
  wev = 2048,
  rec = 4096
}
local PERMDESC = {
  mpm = "Manage permissions",
  mld = "Mount local drives",
  mrd = "Mount remote drives",
  uod = "Unmount other drives",
  mms = "Manage main screen",
  mop = "Manage other programs",
  rod = "Read other drives",
  wod = "Write to other drives",
  rev = "Read environment variables",
  wev = "Set environment variables",
  rec = "Record audio"
}

function _init()
  sys.requestedpermissions(_DRIVE, 1)
  root = Widget:new("permission manager")
  root.children = {}
  root:attachto(nil, false, false)
  view.zindex(root.container, 0)
  knowns = 0
  for i, sym in ipairs(SYMS) do
    knowns = knowns + PERM[sym]
  end
end

function _step(t)
  view.active(root.container)
  if root.children["dia"] then
    sys.stepinterval(64)
    root:step(t)
  else
    sys.stepinterval(1024)
    local drives = fs.drives()
    for i, drive in ipairs(drives) do
      local requested = sys.requestedpermissions(drive)
      if requested > 0 then
        local ungranted = knowns ~ (sys.permissions(drive) & knowns)
        requested = requested & ungranted
      end
      if requested > 0 then
        local demands = ""
        for i, sym in ipairs(SYMS) do
          if requested & PERM[sym] > 0 then
            demands = demands .. " - " .. PERMDESC[sym] .. "\n"
          end
        end
        local dia =
          root:attach(
          "dia",
          Dia.Confirm:new(
            "Permission request",
            "A program on " .. drive .. ": drive\nrequests these permissions:\n\n" .. demands .. "\nGrant permissions?"
          )
        )
        dia.fgcolor = 7
        dia.ondone = function(self, yes)
          if yes then
            sys.permissions(drive, requested | sys.permissions(drive))
          end
          sys.requestedpermissions(drive, requested ~ sys.requestedpermissions(drive))
        end
        dia:focus()
      end
    end
  end
end
