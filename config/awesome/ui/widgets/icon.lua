local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi

return function(args)
    local size = args.size or dpi(30)
    local icon = args.icon or ""
    if args.colour then
        icon = utils.coloured_text(icon, args.colour)
    end

    return wibox.widget {
        valign = "center",
        align = "center",
        markup = icon,
        font = beautiful.icon_font_var .. utils.pixels_to_point(size),
        widget = wibox.widget.textbox
    }
end
