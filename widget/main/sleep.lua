local awful = require("awful")
local gears = require("gears")

local button = require("awbar.widget.wrapper.button")
local sleep_widget = button("sleep")

sleep_widget:buttons(gears.table.join(
    sleep_widget:buttons(),
    awful.button({}, 1, nil, function ()
        os.execute("systemctl suspend")
    end)
))

return sleep_widget