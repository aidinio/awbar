local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local button = require("awbar.widget.wrapper.button")
local restart_widget = button("restart")

restart_widget:buttons(gears.table.join(
    restart_widget:buttons(),
    awful.button({}, 1, nil, function ()
        os.execute("reboot")
    end)
))


return restart_widget