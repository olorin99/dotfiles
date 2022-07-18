local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local system = require("daemons.system")

return function(size)
    
    local temp_text = wibox.widget {
        valign = "center",
        align = "center",
        text = "70°",
        widget = wibox.widget.textbox
    }

    local temp_chart = wibox.widget {
        temp_text,
        colors = { beautiful.colours.lavender },
        bg = beautiful.bg_inactive,
        forced_height = size,
        forced_width = size,
        thickness = size * 0.2,
        rounded_edge = true,
        value = 70,
        max_value = 100,
        min_value = 0,
        start_angle = 3 * math.pi / 2,
        widget = wibox.container.arcchart
    }

    system:connect_signal("temp", function(_, temp)
        temp_chart.value = temp
        temp_text.text = tostring(temp) .. "°"
    end)

    return temp_chart
end
