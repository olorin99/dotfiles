local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local toggle = require("ui.widgets.toggle")
local button = require("ui.widgets.button")
local icon = require("ui.widgets.icon")

return function(args)

    local icon_size = args.height * 0.5
    
    local control_toggle = wibox.widget {
        button({
            height = args.height,
            width = math.ceil(args.width * 0.7),
            bg = beautiful.bg_active,
            shape = utils.prrect(args.border_radius, true, false, false, true),
            child = wibox.widget {
                icon {
                    icon = args.icon,
                    colour = "#000000",
                    size = icon_size
                },
                {
                    valign = "center",
                    align = "center",
                    markup = utils.coloured_text(args.title, "#000000"),
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.flex.horizontal
            }
        },
        function(self)
            self.bg = beautiful.bg_inactive
            args.callback()
        end),
        button({
            height = args.height,
            width = math.ceil(args.width * 0.3),
            bg = beautiful.bg_active,
            shape = utils.prrect(args.border_radius, false, true, true, false),
            child = icon {
                icon = beautiful.right_icon,
                colour = "#000000",
                size = icon_size
            }
        },
        function(self)
            args.sub_callback()
        end),
        layout = wibox.layout.fixed.horizontal
    }

    return control_toggle
end
