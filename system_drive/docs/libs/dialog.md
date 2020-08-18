`dialog` classes
================
Class for creating dialog windows. This should be attached to another widget, like a [`Screen`](screen.md) or [`Window`](window.md).

```lua
local Dia, Window = require("dialog"), require("window")
local win

function _init()
  win = Window:new()
  win:attach("choice", Dia.Choice:new("Question!", "What kind of ice cream do you like?",{
    {label = "Vanilla", action = chosen("vanilla")},
    {label = "Chocolate", action = chosen("chocolate")},
    {label = "Strawberry", action = chosen("strawberry")},
  }))
  win:attach("alert", Dia.Alert:new("For your information!", "You're pretty great!"))
    .ondone = function(alert)
      print("okay? okay..")
    end
  win:attach("confirm", Dia.Confirm:new("Uhmm..", "Are you sure about that?"))
    .ondone = function(confirm, yes)
      if yes then
        print("Okay then..")
      else
        print("Oh good..")
      end
    end
  win:attach("prompt", Dia.Prompt:new("Hey there!", "What's your name?"))
    .ondone = function(prompt, value)
      if value then
        print("Hello "..value.."!")
      else
        print("It's okay to be shy.")
      end
    end
  view.active(win.container)
end

function _step(t)
  win:step(t)
end

function chosen(choice)
  return function()
    print("Excellent choice!")
    print("I like "..choice.." too!")
  end
end
```

`Choice` class
--------------
`Choice` extends [`Window`](window.md)

**`Choice:new(title, message, options): choicedialog`**  
Create a new dialog window with any number of options.

`Alert` class
-------------
`Alert` extends `Choice`.

**`Alert:new(title, message): alert`**  
Create an alert window with a message and an "Okay" button.

**`alert:ondone()`**  
This will be called when the alert is acknowledged.

`Confirm` class
---------------
`Confirm` extends `Choice`.

**`Confirm:new(title, message): confirm`**  
Create a confirmation window with a message and "Yes" and "No" buttons.

**`confirm:ondone(yes)`**  
This will be called when the dialog is answered.


`Prompt` class
--------------
`Prompt` extends `Choice`.

**`Prompt:new(title, message[, defaultvalue]): prompt`**  
Create a prompt window with a message and text input field.

**`prompt:ondone(value)`**  
This will be called when the prompt is answered.

