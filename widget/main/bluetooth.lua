local gears = require("gears")
local awful = require("awful")
local switch = require("awbar.widget.wrapper.switch")

local custom_event = "my_event"

local function bluetooth()
   local bluetooth_widget = switch("bluetooth").widget
   bluetooth_widget.buttons  = gears.table.join(
	  awful.button({}, 1, function ()
            bluetooth_widget:toggle()
	  end)
   )
	return {
		widget = bluetooth_widget,
	}
end

return bluetooth