local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

return function(size)

    local ram_text = wibox.widget {
        markup = "<span color=\"black\">70%</span>",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local ram_chart = wibox.widget {
        ram_text,
        colors = { "#ff0000", "#00ff00" },
        bg = "#0000aa",
        forced_height = size,
        forced_width = size,
        border_width = dpi(0.5),
        border_color = "#000000",
        rounded_edge = true,
        value = 70,
        max_value = 100,
        min_value = 0,
        start_angle = 3 * math.pi / 2,
        widget = wibox.container.arcchart
    }

    awesome.connect_signal("signals::ram", function(used, total)
        local percentage = used / total * 100
        ram_chart.value = percentage
        ram_text.markup = "<span color=\"black\">" .. tostring(math.floor(percentage)) .. "%</span>"

    end)

    return ram_chart
end
