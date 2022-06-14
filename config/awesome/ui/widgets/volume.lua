local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

local gears = require("gears")

local naughty = require("naughty")

return function(size, orientation)

    local volume_slider = wibox.widget {
        bar_shape = utils.rrect(dpi(8)),
        bar_height = size / 2,
        bar_color = "#ff0000",
        bar_active_color = "#00ff00",
        bar_border_width = dpi(0.5),
        bar_border_color = "#000000",
        handle_color = "#00ff00",
        handle_shape = gears.shape.circle,
        handle_width = size / 2 - dpi(0.5),
        forced_width = size,
        forced_height = size / 2,
        value = 70,
        maximum = 100,
        minimum = 0,
        widget = wibox.widget.slider
    }

    local volume = wibox.widget {
        {
            volume_slider,
            direction = orientation or "north",
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
