local awful = require("awful")
local slider = require("awbar.widget.wrapper.slider")
local widget = slider("volume", function(new_value)
    awful.spawn("amixer -D pulse set Master " .. new_value .. "%", false)
end)

return widget
