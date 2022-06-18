local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi

local naughty = require("naughty")

function button_helper(args)
    if args.icon then
        return wibox.widget {
            id = "here_icon_is",
            valign = "center",
            halign = "center",
            image = args.icon,
            widget = wibox.widget.imagebox
        }
    else
        return wibox.widget {
            id = "text_role",
            valign = "center",
            align = "center",
            text = args.text,
            widget = wibox.widget.textbox
        }
    end
end


return function(size, args, func)
    local c = args.client or nil
    local bg = args.bg or "#00ff00"
    local hover = args.hover or args.bg .. "be" or "#ff0000"
    local margins = args.margins or dpi(5)
    local shape = args.shape or gears.shape.circle
    args.text = args.text or ""

    local button = wibox.widget {
        button_helper(args),
        forced_height = size,
        forced_width = size,
        bg = bg,
        shape = shape,
        widget = wibox.container.background
    }

    button:buttons(gears.table.join(
        awful.button({ }, 1, function()
            if func then
                func(button, c)
            end
        end)
    ))

    button:connect_signal("mouse::enter", function()
        button.bg = hover
    end)

    button:connect_signal("mouse::leave", function()
        button.bg = bg
    end)

    if c then
        c:connect_signal("focus", function()
            button.bg = bg
        end)
        c:connect_signal("unfocus", function()
            button.bg = bg .. "64"
        end)
    end

    return button
end
