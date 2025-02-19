local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local function slider(icon_name)
    local bar_widget = wibox.widget.base.make_widget_declarative {
        bar_shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, false,
                true, true,
                false)
        end,
        bar_height = 18,
        bar_color = "#2E3440",
        handle_width        = 2,
        handle_color        = "#ff000001",
        handle_cursor       = "hand2",
        bar_active_color    = "#C6E7FC",
        max_value = 100,
        value = 50,
        forced_height = 19,
        forced_width = 0,
        --paddings = 3,
        background_color = "#2E3440",
        color = "#C6E7FC",
        widget = wibox.widget.slider,
        shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, false,
                true, true,
                false)
        end,
    }
    local slider_widget = wibox.widget.base.make_widget_declarative
        {
            {
                {
                    {
                        image = gears.color.recolor_image(icons(icon_name), "#C6E7FC"),
                        resize = true,
                        forced_width = 18,
                        widget = wibox.widget.imagebox,
                        valign = "center"
                    },
                    widget = wibox.container.margin,
                    left = 5,
                    right = 5
                },
                widget = wibox.container.background,
                forced_height = 19,
                shape = function(cr, width, height)
                    gears.shape.partially_rounded_rect(cr, 100, height, true,
                        false, false, true)
                end,
                bg = "#2E3440",
            },
            bar_widget,
            layout = wibox.layout.align.horizontal,
            update_value = function(new_value)
                bar_widget.value = new_value
            end
        }

    bar_widget:connect_signal("button::press", function(_, lx, ly, _, _, specs)
        naughty.notify { title = "HI" }
        slider_widget.update_value((lx) / (specs.width) * 100)
    end)

    return slider_widget
end

return slider
