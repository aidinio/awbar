local gears = require("gears")
local awful = require("awful")

local switch = require("awbar.widget.wrapper.switch")

local function airplane()
   local microphone_widget = switch("microphone").widget
   microphone_widget.buttons  = gears.table.join(
	  awful.button({}, 1, function ()
            microphone_widget:toggle()
	  end)
   )
	return {
		widget = microphone_widget,
	}
end

return airplane