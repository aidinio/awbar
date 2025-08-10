local awful = require("awful")
local gears = require("gears")
local switch = require("awbar.widget.wrapper.switch")

local function silent()
   local silent_widget = switch("bell-slash").widget
   silent_widget.buttons  = gears.table.join(
	  awful.button({}, 1, function ()
            silent_widget:toggle()
	  end)
   )
	return {
		widget = silent_widget,
	}
end

return silent