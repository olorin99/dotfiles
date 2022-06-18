local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

local gears = require("gears")

local naughty = require("naughty")

return function(args)
    local orientation = args.orientation or "north"
    local colour = args.colour or beautiful.colours.blue
    local height = args.height or dpi(15)
    local width = args.width or height * 2


    local volume_slider = wibox.widget {
        bar_shape = utils.rrect(dpi(8)),
        bar_height = height,
        bar_color = beautiful.panel1,
        bar_active_color = colour,
        bar_border_width = beautiful.border_width,
        bar_border_color = beautiful.border_color,
        handle_color = colour,
        handle_shape = gears.shape.circle,--utils.rrect(dpi(4)),
        handle_width = height - beautiful.border_width,
        forced_width = width,
        forced_height = height,
        value = 70,
        maximum = 100,
        minimum = 0,
        widget = wibox.widget.slider
    }

    local volume = wibox.widget {
        {
            {
                {
                    forced_height = height,
                    forced_width = height,
                    valign = "center",
                    halign = "center",
                    image = beautiful.volume_icon,
                    widget = wibox.widget.imagebox
                },
                volume_slider,
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

    --volume_bar:connect_signal("property::value", function()
    --    awful.spawn.easy_async("amixer set Master " .. volume_bar.value .. "%")
    --end)

    volume_slider:connect_signal("button::press", function()
        button_hold = true
    end)

    -- work around to not flood with volume updates when dragging slider.
    -- button::release signal doesnt work with left click as the signal is
    -- eaten by the sliding handler. use mouse leave for now
    volume_slider:connect_signal("mouse::leave", function()
        if not button_hold then
            return
        end

        awful.spawn("amixer set Master " .. volume_slider.value .. "%")
        button_hold = false
    end)

    awesome.connect_signal("signals::volume", function(value)
        if button_hold then
            return
        end

        volume_slider.value = value
    end)

    return volume

end
