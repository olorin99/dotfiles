local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local system = require("daemons.system")

return function(size)
    
    local disk_text = wibox.widget {
        valign = "center",
        align = "center",
        text = "70",
        widget = wibox.widget.textbox
    }

    local disk_chart = wibox.widget {
        disk_text,
        colors = { beautiful.colours.sapphire },
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

    system:connect_signal("disk", function(_, size, used)
        disk_chart.value = math.floor(used / 1000000)
        disk_chart.max_value = math.floor(size / 1000000)
        disk_text.text = tostring(math.floor(used / 1000000)) .. "G"
    end)

    return disk_chart
end
