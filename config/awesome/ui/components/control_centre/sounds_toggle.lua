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

    local players = wibox.widget {
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
        widget = wibox.container.background
    }

    local submenu = wibox.widget {
        {
            button({
                width = args.width * 0.4,
                height = dpi(30),
                bg = beautiful.active,
                shape = utils.rrect(dpi(8)),
                child = wibox.widget {
                    valign = "center",
                    align = "center",
                    markup = utils.coloured_text("Sound", "#000000"),
                    widget = wibox.widget.textbox
                }
            }, function(self)
                awesome.emit_signal("audio::mute")
            end),
            button({
                width = args.width * 0.4,
                height = dpi(30),
                bg = beautiful.active,
                shape = utils.rrect(dpi(8)),
                child = wibox.widget {
                    valign = "center",
                    align = "center",
                    markup = utils.coloured_text("Mute", "#000000"),
                    widget = wibox.widget.textbox
                }
            }, function(self)
                awesome.emit_signal("audio::mute")
            end),
            spacing = dpi(5),
            layout = wibox.layout.flex.horizontal
        },
        players,
        visible = false,
        forced_height = height,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    submenu:connect_signal("mouse::leave", function()
        submenu.visible = false
        args.toggles.visible = true
    end)


    local sounds_text = wibox.widget {
        valign = "center",
        align = "center",
        markup = utils.coloured_text("Sound", "#000000"),
        widget = wibox.widget.textbox
    }

    local sounds_toggle = wibox.widget {
        toggle({
            height = args.height,
            width = math.ceil(args.width * 0.7),
            shape = utils.prrect(args.border_radius, true, false, false, true),
            child = wibox.widget {
                icon {
                    icon = beautiful.volume_icon,
                    colour = "#000000",
                    size = icon_size
                },
                sounds_text,
                layout = wibox.layout.flex.horizontal
            }
        }, function()
            awesome.emit_signal("audio::toggle")
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

    awesome.connect_signal("audio::toggle", function()
        if not sounds_toggle.children[1]:toggle() then
            sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
            sounds_text.markup = utils.coloured_text("Mute", "#000000")
        else
            sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
            sounds_text.markup = utils.coloured_text("Sound", "#000000")
        end
    end)

    awesome.connect_signal("audio::mute", function()
        sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
        sounds_text.markup = utils.coloured_text("Mute", "#000000")
        if sounds_toggle.children[1].state then sounds_toggle.children[1]:toggle() end
    end)
    awesome.connect_signal("audio::unmute", function()
        sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
        sounds_text.markup = utils.coloured_text("Sounds", "#000000")
        if sounds_toggle.children[1].state then sounds_toggle.children[1]:toggle() end
    end)

    return sounds_toggle, submenu
end
