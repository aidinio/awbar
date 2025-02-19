local slider = require("hover.widget.wrapper.slider")
local naughty = require("naughty")

local Gio = require("lgi").Gio
local GLib = require("lgi").GLib

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
    local scaled = 100 + 24900 * (val / 100) ^ 3
    print(scaled)
    set_brightness(scaled)
end
local widget = slider("brightness-half", update_brightness)

return widget
