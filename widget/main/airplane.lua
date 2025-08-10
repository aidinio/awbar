local gears = require("gears")
local awful = require("awful")
local switch = require("awbar.widget.wrapper.switch")

local function airplane()
   local airplane_widget = switch("airplane").widget
   airplane_widget.buttons  = gears.table.join(
	  awful.button({}, 1, function ()
			airplane_widget:toggle()
	  end)
   )
	return {
		widget = airplane_widget,
	}
end

return airplane