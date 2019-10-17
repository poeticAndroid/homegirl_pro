local Window, ui = require("window"), require("ui")

local Choice = Window:extend()
do
  function Choice:_new(title, message, options)
    if not options then
      options = {
        {
          label = "'kay",
          action = function(self)
            self.result = "bleh"
          end
        }
      }
    end
    self.message = message
    self.options = options
    Window._new(self, title, 8, 8, 320, 80)
  end

  function Choice:attachto(parent, vp, screen)
    Window.attachto(self, parent, screen or false, screen or false)
    if parent then
      local cw, ch = view.size(self.container)
      local vw, vh = view.size(self.mainvp)
      self.onclose = nil
      self.onhide = nil
      local msg = Window.attach(self, "message", ui.Label:new(self.message))
      local mw, mh = msg:autosize()
      msg:position(4, 4)
      local totbw = 0
      for i, option in ipairs(self.options) do
        local btn = Window.attach(self, "button_" .. i, ui.Button:new(option.label))
        local bw, bh = btn:autosize()
        totbw = totbw + bw
        mw = math.max(mw, totbw + 6)
        btn:position(mw / 2 - bw / 2 + 4, mh + 8)
        btn.onclick = function()
          self._action = option.action
        end
      end
      if #(self.options) > 1 then
        local spc = (mw - totbw) / (#(self.options) - 1)
        local bl, bt = self.children["button_1"]:position()
        bl = 4
        for i, option in ipairs(self.options) do
          local btn = self.children["button_" .. i]
          local bw, bh = btn:size()
          btn:position(bl, bt)
          bl = bl + bw + spc
        end
      end
      local bw, bh = self.children["button_1"]:size()

      cw, ch = self:size(mw + 8 + (cw - vw), mh + bh + 12 + (ch - vh))
      local pl, pt = parent:position()
      local pw, ph = parent:size()
      self:position(pl + pw / 2 - cw / 2, pt + ph / 2 - ch / 2)
    end
  end

  function Choice:attach(name, child)
    child = Window.attach(self, name, child)
    local cw, ch = child:autosize()
    local vw, vh = view.size(self.mainvp)
    for i, option in ipairs(self.options) do
      local btn = self.children["button_" .. i]
      local bl, bt = btn:position()
      btn:position(bl, bt + ch + 4)
    end
    local msg = self.children["message"]
    local mw, mh = msg:size()
    child:position(4, mh + 8)
    child:size(vw - 8, ch)
    vw, vh = self:size()
    self:size(vw, vh + ch + 4)
    return child
  end

  function Choice:step(t)
    Window.step(self, t)
    if self._action ~= nil then
      self.parent:destroychild(self)
      self:_action()
    end
  end
end

local Alert = Choice:extend()
do
  function Alert:_new(title, message)
    options = {
      {
        label = "Okay",
        action = function(self)
          if self.ondone then
            self:ondone()
          end
        end
      }
    }
    Choice._new(self, title, message, options)
  end
end

local Confirm = Choice:extend()
do
  function Confirm:_new(title, message)
    options = {
      {
        label = "No",
        action = function(self)
          if self.ondone then
            self:ondone(false)
          end
        end
      },
      {
        label = "Yes",
        action = function(self)
          if self.ondone then
            self:ondone(true)
          end
        end
      }
    }
    Choice._new(self, title, message, options)
  end
end

local Prompt = Choice:extend()
do
  function Prompt:_new(title, message, defaultvalue)
    options = {
      {
        label = "Cancel",
        action = function(self)
          if self.ondone then
            self:ondone(false)
          end
        end
      },
      {
        label = "Okay",
        action = function(self)
          if self.ondone then
            self:ondone(self.result)
          end
        end
      }
    }
    self.result = defaultvalue or ""
    Choice._new(self, title, message, options)
  end

  function Prompt:attachto(parent, vp, screen)
    Choice.attachto(self, parent, vp, screen)
    if parent then
      local txtinp = self:attach("input", ui.TextInput:new(self.result))
      txtinp.onchange = function()
        self.result = txtinp.content
      end
      txtinp.onenter = function()
        self._action = function(self)
          if self.ondone then
            self:ondone(self.result)
          end
        end
      end
      txtinp:focus()
    end
  end
end

return {
  Choice = Choice,
  Alert = Alert,
  Confirm = Confirm,
  Prompt = Prompt
}
