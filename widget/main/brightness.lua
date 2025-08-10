local slider = require("awbar.widget.wrapper.slider")
local naughty = require("naughty")

local Gio = require("lgi").Gio
local GLib = require("lgi").GLib
local gears = require("gears")

local to_brightness_map = {}
local from_brightness_map = {}

local function percentage_to_brightness(p)
    return math.floor(100 + 23900 * (p / 100) ^ 3)
end

for i = 0, 100 do
    local brightness = percentage_to_brightness(i)
    from_brightness_map[brightness] = i
    to_brightness_map[i] = brightness
end

local last_defined = -1
for i=1,24000 do
    if from_brightness_map[i] then
        last_defined = from_brightness_map[i]
    else
        from_brightness_map[i] = last_defined
    end
end

local latest_time = 0


local function set_brightness(val)
    local bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, nil)
    bus:call_sync(
        "org.freedesktop.login1",
        "/org/freedesktop/login1/session/auto",
        "org.freedesktop.login1.Session",
        "SetBrightness",
        GLib.Variant("(ssu)", { "backlight", "intel_backlight", val }),
        nil,
        Gio.DBusCallFlags.NONE,
        -1
    )
end

local update_brightness = function(val)
    latest_time = os.time()
    gears.timer {
        timeout = 2,
        call_now = true,
        autostart = true,
        single_shot = true,
        callback = function()
            if os.time() - latest_time > 1 then
                print("Disabling")
                latest_time = 0
            end
        end
    }
    local scaled = 100 + 23900 * (val / 100) ^ 3
    -- print(scaled)
    set_brightness(scaled)
end
local widget = slider("brightness-half", update_brightness, 24000)

gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        local brightness = {
            file = '/sys/class/backlight/intel_backlight/brightness',
            max = 24000,
            current = 0,
        }

        local monitor = Gio.File.new_for_path(brightness.file):monitor_file('NONE')

        monitor.on_changed = function(self, file, _, event_type)
            if event_type ~= 'CHANGED' then return end

            file:load_bytes_async(nil, function(_, task)
                local bytes = file:load_bytes_finish(task)

                if not bytes or not bytes:get_data(-1) then return end

                local brightness_new = tonumber(bytes:get_data(-1))

                if brightness_new ~= brightness.current then
                    local percentage = (100 ^ 3 * (brightness_new - 100) / 23900) ^ (1 / 3);
                    print(latest_time)
                    if (latest_time == 0) then
                        print("Syncing slider", widget.get_value(), from_brightness_map[brightness_new])
                        widget.update_value(from_brightness_map[brightness_new])
                    end
                end
            end)
        end
    end
}

return widget
