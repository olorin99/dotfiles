local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi

local gears = require("gears")

local icon = require("ui.widgets.icon")

return function(args)
    local orientation = args.orientation or "north"
    local colour = args.colour or beautiful.colours.rosewater
    local height = args.height or dpi(15)
    local width = args.width or height * 2


    local brightness_slider = wibox.widget {
        bar_shape = utils.rrect(dpi(25)),
        bar_height = height,
        bar_color = beautiful.bg_inactive,
        bar_active_color = colour,
        bar_border_width = beautiful.border_width,
        handle_color = colour,
        handle_shape = function(cr, h, w)
            utils.rrect(dpi(6))(cr, height, height)
        end,
        --handle_shape = gears.shape.circle,
        handle_width = height,
        forced_width = width,
        forced_height = height,
        value = 70,
        maximum = 100,
        minimum = 0,
        widget = wibox.widget.slider
    }

    local brightness = wibox.widget {
        {
            {
                icon({ size = height, icon = beautiful.brightness_icon }),
                brightness_slider,
                spacing = dpi(5),
                layout = wibox.layout.fixed.horizontal
            },
            direction = orientation,
            widget = wibox.container.rotate
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    }

    local button_hold = false

    brightness_slider:connect_signal("button::press", function()
        button_hold = true
    end)
    
    brightness_slider:connect_signal("mouse::leave", function()
        if not button_hold then
            return
        end

        awful.spawn("brightnessctl set " .. brightness_slider.value .. "% -q")
        button_hold = false
    end)

    awesome.connect_signal("signals::brightness", function(value)
        brightness_slider.value = value
    end)

    return brightness
end
