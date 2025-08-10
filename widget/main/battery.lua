local gears = require("gears")
local math = math

local status_bar = require("awbar.widget.wrapper.status_bar")
local battery_bar = status_bar("battery-charging", "#A3BE8C", "#36402E", 75)

gears.timer {
    
    callback = function ()
        awesome.connect_signal("battery::changed", function (a)
            local final_value = math.floor(a.percentage)
            battery_bar.update_value(final_value)
            battery_bar.update_icon(a.icon_path)
            if a.icon_path:match("([^/]+)$") == "battery-charging.svg" then
                battery_bar.update_foreground("#A3BE8C")
                battery_bar.update_background("#36402E")
            elseif final_value < 30 then
                battery_bar.update_foreground("#BF616A")
                battery_bar.update_background("#402E2E")
            elseif final_value < 70 then
                battery_bar.update_foreground("#C6E7FC")
                battery_bar.update_background("#2E3440")
            else
                battery_bar.update_foreground("#A3BE8C")
                battery_bar.update_background("#36402E")
            end
        end)
    end,
    autostart = true,
    call_now = true,
    timeout = 0,
    single_shot = true
}

return battery_bar