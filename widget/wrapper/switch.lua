local gears = require("gears")
local wibox = require("wibox")
local cairo = require("lgi").cairo

local function svgsurf(context, cr, width, height)
	width = 30
	height = 30
	-- naughty.notify({
	-- 	title = "WOWW",
	-- 	text = "HELLO"
	-- })
	-- local svg_surface = gears.surface("/home/aidin/.config/awesome/awbar.theme/nord_m/icon/bluetooth-connected.svg")

	-- local image_surface = gears.surface("/home/aidin/.config/awesome/awbar.theme/nord_m/icon/bluetooth-connected.svg")
	-- local resized_image_surface = cairo.ImageSurface(cairo.Format.RGB24, height, height)
	-- local resized_cr = cairo.Context(resized_image_surface)
	
	-- resized_cr:scale(height / image_surface.width, height / image_surface.height)
	-- resized_cr:set_source_surface(image_surface, 0, 0)
	-- resized_cr:paint()
	-- -- naughty.notify({
	-- -- 	title = "svg_surface",
	-- -- 	text = "svg_surface " .. svg_surface.width
	-- -- })
	-- -- local resized_surface = svg_surface:take_surface()
	-- -- local cr = cairo.Context(resized_surface)
	-- -- cr:set_source_surface(svg_surface, 0, 0)
	-- -- cr:rectangle(0, 0, width, height)
	-- -- cr:fill()
	-- cr:set_source_surface(resized_image_surface, 0, 0)
	-- cr:paint()
	-- return svg_surface
end

local function switch(icon)
	icon = icon or "bluetooth-connected"

	local icon_widget = wibox.widget.base.make_widget_declarative {
		-- image = gears.color.recolor_image(icons(icon), "#2E3440"),
		image = icons(icon),
		resize = true,
		forced_width = 26,
		widget = wibox.widget.imagebox,
		stylesheet = "* { fill: #0E3440 }",
		valign = "center",
		halign = "center",
		update_color = function(self, color)
			self.stylesheet = string.format("* { fill: %s} ", color)
		end
	}
	
	return {
		widget = wibox.widget.base.make_widget_declarative {
			{
				icon_widget,
				widget = wibox.container.place,
			},
			widget = wibox.container.background,
			bg = "#C6E7FC",
			shape = function(cr)
				gears.shape.rounded_rect(cr, 45, 45, 30)
			end,
			bgimage = function(context, cr, width, height)
				return svgsurf(context, cr, width, height)
			end,
			state = true,
			forced_width = 45,
			toggle = function(self, state)
				if state == "off" then
					self.bg = "#2E3440"
					icon_widget:update_color("#9A9EA6")
					self.state = false
				elseif state=="on" then
					self.bg = "#C6E7FC"
					icon_widget:update_color("#0E3440")
					self.state = true
				elseif state == nil then
					if self.state == false then
						self:toggle("on")
					elseif self.state == true then
						self:toggle("off")
					end
				end
			end,
			update_icon = function (new_icon)
				icon_widget.image = icons(icon)
			end
		}
	}
end

return switch
