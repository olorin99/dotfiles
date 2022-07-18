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
    
    local submenu = wibox.widget {
        button({
            width = args.width,
            height = args.toggles_height / 3,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Screen", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
                if not (exit_code == 0) then
                    return
                end
            naughty.notify { title = "Screenshot", message = stdout }
            end)
        end),
        button({
            width = args.width,
            height = args.toggles_height / 3,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Window", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim -i $(xdotool getactivewindow) $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end

            naughty.notify { title = "Screenshot", message = stdout }
            end)
        end),
        button({
            width = args.width,
            height = args.toggles_height / 3,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Screen", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim -s $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end

            naughty.notify { title = "Screenshot", message = stdout }
            end)
        end),
        visible = false,
        forced_height = args.toggles_height,
        spacing = dpi(5),
        layout = wibox.layout.flex.vertical
    }

    submenu:connect_signal("mouse::leave", function(self)
        self.visible = false
        args.toggles.visible = true
    end)

    local screenshot_toggle = wibox.widget {
        button({
            height = args.height,
            width = math.ceil(args.width * 0.7),
            bg = beautiful.active,
            shape = utils.prrect(args.border_radius, true, false, false, true),
            child = wibox.widget {
                icon {
                    icon = beautiful.screenshot_icon,
                    colour = "#000000",
                    size = icon_size
                },
                {
                    valign = "center",
                    align = "center",
                    markup = utils.coloured_text("Screenshot", "#000000"),
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.flex.horizontal
            }
        }, function(self)
            self.bg = beautiful.panel1,
            gears.timer({
                timeout = 3,
                single_shot = true,
                callback = function()
                    self.bg = beautiful.active
                end
            }):again()
            awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
                if not (exit_code == 0) then
                    return
                end
                naughty.notify { title = "Screenshot", message = stdout }
            end)
        end),
        button({
            height = args.height,
            width = math.floor(args.width * 0.3),
            shape = utils.prrect(args.border_radius, false, true, true, false),
            child = icon {
                icon = beautiful.right_icon,
                colour = "#000000",
                size = icon_size
            }
        }, function()
            args.toggles.visible = false
            submenu.visible = true
        end),
        layout = wibox.layout.fixed.horizontal
    }

    return screenshot_toggle, submenu
end
