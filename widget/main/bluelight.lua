local gears = require("gears")
local awful = require("awful")

local switch = require("awbar.widget.wrapper.switch")

function bluelight()
   local bluelight_widget = switch("eyeglasses").widget
   bluelight_widget.buttons  = gears.table.join(
	  awful.button({}, 1, function ()
            bluelight_widget:toggle()
	  end)
   )
	return {
		widget = bluelight_widget,
	}
end

return bluelight