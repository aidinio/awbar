local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local button = require("awbar.widget.wrapper.button")
local lock_widget = button("lock")

lock_widget:buttons(gears.table.join(
    lock_widget:buttons(),
    awful.button({}, 1, nil, function ()
        os.execute("i3lock")
    end)
))

return lock_widget