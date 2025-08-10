local gears = require("gears")
local math = math

local status_bar = require("awbar.widget.wrapper.status_bar")
local ram_bar = status_bar("ram", "#C6E7FC", "#2E3440", 50)

gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function ()
        local command = io.popen("free")
        local result = command:read("*a")
        command:close()
        for line in result:gmatch("[^\n]+") do
            if line:find("Mem:") then
                local total, used = line:match("%s+(%d+)%s+(%d+)")
                local total = tonumber(total)
                local used = tonumber(used)
                local free = tonumber(free)
                local final_value = math.floor(used / total * 100)
                ram_bar.update_value(final_value)
                if final_value < 40 then
                    ram_bar.update_foreground("#A3BE8C")
                    ram_bar.update_background("#36402E")
                elseif final_value < 80 then
                    ram_bar.update_foreground("#C6E7FC")
                    ram_bar.update_background("#2E3440")
                else
                    ram_bar.update_foreground("#BF616A")
                    ram_bar.update_background("#402E2E")
                end
            end
        end
    end
}

return ram_bar