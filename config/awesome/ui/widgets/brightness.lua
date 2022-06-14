local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi

return function(size, orientation)

--[[    local brightness_widget = wibox.widget {
        {
            {
                id = "brightness_bar",
                color = "#00ff00",
                border_width = dpi(0.5),
                border_color = "#000000",
                forced_height = size / 2,
                forced_width = size,
                shape = shapes.rrect(dpi(6)),
                bar_shape = shapes.rrect(dpi(3)),
                value = 70,
                max_value = 100,
                widget = wibox.widget.progressbar
            },
            direction = orientation or "north",
            widget = wibox.container.rotate
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    }

    awesome.connect_signal("signals::brightness", function(value)
        brightness_widget:get_children_by_id("brightness_bar")[1].value = value
    end)
]]--


    local brightness_slider = wibox.widget {
        bar_shape = utils.rrect(dpi(8)),
        bar_height = size / 2,
        bar_color = "#ff0000",
        bar_border_width = dpi(0.5),
        bar_border_color = "#000000",
        handle_color = "#000000",
        handle_shape = utils.rrect(dpi(4)),
        handle_width = size / 2,
        forced_width = size,
        forced_height = size / 2,
        value = 70,
        maximum = 100,
        minimum = 0,
        widget = wibox.widget.slider
    }

    local brightness = wibox.widget {
        {
            brightness_slider,
            direction = orientation or "north",
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
