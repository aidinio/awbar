local gears = require("gears")
local math = math

local status_bar = require("awbar.widget.wrapper.status_bar")
local cpu_bar = status_bar("cpu", "#BF616A", "#402E2E", 100)

local last_total = 0
local last_used = 0

gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        local cpu_file = io.open("/proc/stat", "r")
        local line = cpu_file:read("*l")
        cpu_file:close()
        local cpu, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = line:match(
        "(%S+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        local total = user + nice + system + idle + iowait + irq + softirq + steal
        local used = user + nice + system + iowait + irq + softirq + steal
        local final_value = math.floor((used - last_used) / (total - last_total) * 100)
        last_total = total
        last_used = used
        cpu_bar.update_value(final_value)
        if final_value < 40 then
            cpu_bar.update_foreground("#A3BE8C")
            cpu_bar.update_background("#36402E")
        elseif final_value < 80 then
            cpu_bar.update_foreground("#C6E7FC")
            cpu_bar.update_background("#2E3440")
        else
            cpu_bar.update_foreground("#BF616A")
            cpu_bar.update_background("#402E2E")
        end
    end
}

return cpu_bar
