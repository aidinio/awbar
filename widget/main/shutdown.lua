local awful = require("awful")
local gears = require("gears")

local button = require("awbar.widget.wrapper.button")
local shutdown_widget = button("power")

shutdown_widget:buttons(gears.table.join(
    shutdown_widget:buttons(),
    awful.button({}, 1, nil, function ()
        os.execute("shutdown now")
    end)
))

return shutdown_widget