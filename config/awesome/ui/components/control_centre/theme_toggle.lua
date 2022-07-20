local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local control_toggle = require("ui.components.control_centre.toggle")

return function(args)

    local toggle = control_toggle({
        title = "Theme",
        height = args.height,
        width = args.width,
        border_radius = args.border_radius,
        callback = function()

        end,
        sub_callback = function()

        end
    })

    return toggle
end
