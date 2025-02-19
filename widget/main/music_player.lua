local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local lgi = require("lgi")
local cairo = lgi.cairo
local Gio = lgi.Gio
local GLib = lgi.GLib

local bus = Gio.bus_get_sync(Gio.BusType.SESSION, nil)

local function make_background(context, cr, width, height, image_path)
    local image_surface = cairo.ImageSurface.create_from_png(file_path .. "/demo_assets/song_cover.png")
    local resized_image_surface = cairo.ImageSurface(cairo.Format.RGB24, height, height)
    local resized_cr = cairo.Context(resized_image_surface)

    resized_cr:scale(height / image_surface.width, height / image_surface.height)
    resized_cr:set_source_surface(image_surface, 0, 0)
    resized_cr:paint()

    local main_surface = cairo.ImageSurface(cairo.Format.RGB24, 450, height)
    local main_cr = cairo.Context(main_surface)
    -- main_cr:set_source_rgb(0.082, 0.098, 0.11)
    main_cr:set_source_rgb(1, 0, 0)
    main_cr:paint()
    main_cr:set_source_surface(resized_image_surface, 405 - height + 2, 0)
    main_cr:paint()
    local my_gradient = cairo.Pattern.create_linear(0, 0, width, 0)
    my_gradient:add_color_stop_rgba(0, gears.color.parse_color("#15191CFF"))
    my_gradient:add_color_stop_rgba((405 - height) / width, gears.color.parse_color("#15191CFF"))
    my_gradient:add_color_stop_rgba(1, gears.color.parse_color("#15191C00"))
    main_cr:set_source(my_gradient)
    main_cr:paint()
    cr:set_source_surface(main_surface, 0, 0)
    cr:paint()
    -- return main_surface
end

local function get_metadata(service, data)
    local names = bus:call_sync(
        "org.freedesktop.DBus",
        "/",
        "org.freedesktop.DBus",
        "ListNames",
        nil,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)
end

local function active_players()
    local names = bus:call_sync(
        "org.freedesktop.DBus",
        "/",
        "org.freedesktop.DBus",
        "ListNames",
        nil,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)

    local name_array = names[1]
    local active_players = {}
    -- print(names[2])
    for _, name in ipairs(name_array) do
        if string.find(name, "mpris") then
            table.insert(active_players, name)
        end
    end

    return active_players
end

local function play_pause(service)
    bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "PlayPause",
        nil,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)
end

local function next(service)
    bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "Next",
        nil,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)
end

local function previous(service)
    bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "Previous",
        nil,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)
end

local function next(service)
    bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "Next",
        nil,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)
end

local function set_position(service)
    bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "SetPosition",
        nil,
        nil,
        Gio.DBusCallFlags.NONE, 2
        - 1)
end

local function get_track_id(service)
    local params = GLib.Variant.new_tuple({
        GLib.Variant.new_string("org.mpris.MediaPlayer2.Player"),
        GLib.Variant.new_string("Metadata")
    })

    local result = bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.freedesktop.DBus.Properties",
        "Get",
        params,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)

    -- TODO: Access trackid with O(1)
    local track_id = nil
    for key, value in result[1]:pairs() do
        print(key, value)
        if key == "mpris:trackid" then
            naughty.notify { title = value:get_string() }
            track_id = value:get_string()
            return track_id
        end
    end
end

-- xesam:title
local function get_track_name(service)
    local params = GLib.Variant.new_tuple({
        GLib.Variant.new_string("org.mpris.MediaPlayer2.Player"),
        GLib.Variant.new_string("Metadata")
    })

    local result, err = bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.freedesktop.DBus.Properties",
        "Get",
        params,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)
    if err then
        naughty.notify { title = tostring(err) }
        return nil
    end
    -- TODO: Access trackname with O(1)
    local track_name = nil
    for key, value in result[1]:pairs() do
        print(key, value)
        if key == "xesam:title" then
            naughty.notify { title = value:get_string() }
            track_name = value:get_string()
            return track_name
        end
    end
end

local function get_album_art(service)
    local params = GLib.Variant.new_tuple({
        GLib.Variant.new_string("org.mpris.MediaPlayer2.Player"),
        GLib.Variant.new_string("Metadata")
    })

    local result = bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.freedesktop.DBus.Properties",
        "Get",
        params,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)

    -- TODO: Access trackname with O(1)
    local track_name = nil
    for key, value in result[1]:pairs() do
        print(key, value)
        if key == "mpris:artUrl" then
            naughty.notify { title = value:get_string() }
            track_name = value:get_string()
            return track_name
        end
    end
end

local function get_artist_name(service)
    local params = GLib.Variant.new_tuple({
        GLib.Variant.new_string("org.mpris.MediaPlayer2.Player"),
        GLib.Variant.new_string("Metadata")
    })

    local result, err = bus:call_sync(string.format("org.mpris.MediaPlayer2.%s", service),
        "/org/mpris/MediaPlayer2",
        "org.freedesktop.DBus.Properties",
        "Get",
        params,
        nil,
        Gio.DBusCallFlags.NONE,
        -1)

    -- TODO: Access trackname with O(1)
    local artist_name = nil
    if err then
        naughty.notify { title = tostring(err) }
        return nil
    end
    for key, value in result[1]:pairs() do
        print(key, value)
        if key == "xesam:artist" then
            naughty.notify { title = value:get_string() }
            artist_name = value:get_child_value(0):get_string()
            return artist_name
        end
    end
end


local function music_player()
    local all_players = active_players()
    local current_player_index = 1
    if all_players[current_player_index] ~= nil then
        local current_player_name = all_players[current_player_index]:match("([^%.]+)$")
    end
    local current_player_widget = wibox.widget.base.make_widget_declarative {
        markup = current_player_name,
        widget = wibox.widget.textbox,
    }


    local play_button = wibox.widget.base.make_widget_declarative {
        image = gears.color.recolor_image(icons("play-bold"), "#C6E7FC"),
        resize = true,
        forced_width = 24,
        widget = wibox.widget.imagebox,
        valign = "center",
    }

    local previous_button = wibox.widget.base.make_widget_declarative {
        image = gears.color.recolor_image(icons("skip-back-bold"), "#C6E7FC"),
        resize = true,
        forced_width = 24,
        widget = wibox.widget.imagebox,
        valign = "center",
    }

    local next_button = wibox.widget.base.make_widget_declarative {
        image = gears.color.recolor_image(icons("skip-forward-bold"), "#C6E7FC"),
        resize = true,
        forced_width = 24,
        widget = wibox.widget.imagebox,
        valign = "center",
    }

local slider_widget = wibox.widget.base.make_widget_declarative {
        bar_shape           = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 20)
        end,
        bar_height          = 18,
        bar_color           = "#2E3440",
        handle_width        = 0,
        handle_color        = "#ff000000",
        handle_cursor       = "hand2",
        bar_active_color    = "#C6E7FC",
        handle_border_color = "#ff0000",
        handle_border_width = 0,
        value               = 25,
        widget              = wibox.widget.slider,
        forced_width        = 100,
        minimum             = 0,
    }

    slider_widget:connect_signal("property::value", function(_, new_value)
        naughty.notify { title = "Slider changed", message = tostring(new_value) }
    end)
    play_button:connect_signal("button::press", function() play_pause(current_player_name) end)
    previous_button:connect_signal("button::press", function() previous(current_player_name) end)
    next_button:connect_signal("button::press",
        function()
            next(current_player_name); naughty.notify { title = get_album_art(current_player_name) }
        end)

    local track_name_widget = wibox.widget.base.make_widget_declarative {
        markup = string.format("<span foreground='%s'>%s - %s</span>", colors.text,
            get_track_name(current_player_name), get_artist_name(current_player_name)),
        font = fonts.panel.music_player.song_title,
        align = "left",
        forced_width = 300,
        forced_height = 1,
        widget = wibox.widget.textbox,
    }

    current_player_widget:connect_signal("button::press", function()
        current_player_index = (current_player_index % #all_players) + 1
        naughty.notify { title = tostring((current_player_index)) }
        current_player_name = all_players[current_player_index]:match("([^%.]+)$")
        current_player_widget.markup = current_player_name
        track_name_widget.markup = string.format("<span foreground='%s'>%s - %s</span>", colors.text,
            get_track_name(current_player_name), get_artist_name(current_player_name))
    end)

    return {
        {
            {
                {
                    current_player_widget,
                    track_name_widget,
                    layout = wibox.layout.fixed.horizontal
                },
                {
                    slider_widget,
                    layout = wibox.layout.fixed.vertical,
                    forced_height = 30
                },
                {
                    {
                        markup = string.format("<span foreground='%s'>31:38/53:80</span>", colors.text),
                        font = fonts.panel.music_player.duration,
                        align = "center",
                        widget = wibox.widget.textbox,
                    },
                    {

                        {
                            previous_button,
                            play_button,
                            next_button,
                            layout = wibox.layout.fixed.horizontal,
                            spacing = 20
                        },
                        widget = wibox.container.margin,
                        left = 65
                    },
                    layout = wibox.layout.align.horizontal
                },
                layout = wibox.layout.fixed.vertical,
                spacing = 20
            },
            widget = wibox.container.margin,
            left = 15,
            top = 20,
            right = 15,
            bottom = 20,
        },
        widget = wibox.container.background,
        bg = "#15191C",
        -- bg = "linear:0,0:400,0:0,#ff0000:1,#0000ff00",
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, 150)
        end,
        bgimage = function(context, cr, width, height)
            make_background(context, cr, width, height)
        end,
        forced_height = 150,
    }
end

return music_player
