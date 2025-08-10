local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local switch = require("awbar.widget.wrapper.switch")
local GLib = require("lgi").GLib
local Gio = require("lgi").Gio
local NM = require("lgi").NM

local function wifi()
	local wifi_widget      = switch("wifi-high-bold").widget
	local WIFI_DEVICE_TYPE = 2
	local bus              = Gio.bus_get_sync(Gio.BusType.SYSTEM, nil)
	function onDBusSignalCallback()
		local devices = bus:call_sync("org.freedesktop.NetworkManager",
			"/org/freedesktop/NetworkManager",
			"org.freedesktop.NetworkManager",
			"GetDevices",
			nil,
			nil,
			Gio.DBusCallFlags.NONE,
			-1)
		-- print(devices)
		for key, value in ipairs(devices[1]) do
			local device_path = value
			local device_type_params = GLib.Variant.new_tuple({
				GLib.Variant.new_string("org.freedesktop.NetworkManager.Device"),
				GLib.Variant.new_string("DeviceType")
			})
			local get_device_type_result = bus:call_sync("org.freedesktop.NetworkManager",
				device_path,
				"org.freedesktop.DBus.Properties",
				"Get",
				device_type_params,
				nil,
				Gio.DBusCallFlags.NONE,
				-1) -- lgi.rec 0xADRESS:GLib.Variant
			local data = get_device_type_result[1]
			local device_type = data.value
			if device_type == WIFI_DEVICE_TYPE then
				print(device_path .. " Is a wifi!")
				naughty.notify { title = device_path .. " is a wifi!" }
				local state_params = GLib.Variant.new_tuple({
					GLib.Variant.new_string("org.freedesktop.NetworkManager.Device"),
					GLib.Variant.new_string("State")
				})
				local get_state_result = bus:call_sync("org.freedesktop.NetworkManager",
					device_path,
					"org.freedesktop.DBus.Properties",
					"Get",
					state_params,
					nil,
					Gio.DBusCallFlags.NONE,
					-1)
				local data = get_state_result[1]
				local state = data.value
				if state == 100 then
					naughty.notify { title = "connected!" }
					wifi_widget:toggle("on")
				elseif state == 50 or state == 60 then
					naughty.notify { title = "connecting" }
				else
					naughty.notify { title = "disconnected!" }
					wifi_widget:toggle("off")
				end
			end
		end
	end

	local sub_id = bus:signal_subscribe("org.freedesktop.NetworkManager", "org.freedesktop.DBus.Properties",
		"PropertiesChanged", "/org/freedesktop/NetworkManager", nil, Gio.DBusSignalFlags.NONE, onDBusSignalCallback)
	gears.timer{timeout = 0, autostart = true, start_now = true, single_shot = true,callback = onDBusSignalCallback}
	wifi_widget.buttons = gears.table.join(
		awful.button({}, 1, function() -- TODO: call disconnect on dbus and toggle on success (check with propertyChanged)
			wifi_widget:toggle()
		end)
	)
	return {
		widget = wifi_widget,
	}
end

return wifi
