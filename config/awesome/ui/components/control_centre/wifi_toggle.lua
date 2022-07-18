local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local network = require("daemons.network")
local scrollable = require("ui.widgets.scrollable")
local toggle = require("ui.widgets.toggle")
local button = require("ui.widgets.button")
local icon = require("ui.widgets.icon")

return function(args)
    local icon_size = args.height * 0.5

    local available_wifi = wibox.widget {
        visible = true,
        spacing = dpi(5),
        layout = scrollable.vertical
    }

    local submenu = wibox.widget {
        button({
            width = dpi(30),
            bg = beautiful.active,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Scan", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            network:scan_networks()
        end),
        available_wifi,
        visible = false,
        forced_height = height,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
    }

    submenu:connect_signal("mouse::leave", function(self)
        self.visible = false
        args.toggles.visible = true
    end)
    



    local ssid_text = wibox.widget {
        valign = "center",
        align = "center",
        markup = utils.coloured_text("None", "#000000"),
        widget = wibox.widget.textbox
    }

    local wifi_toggle = wibox.widget {
        toggle({
            height = args.height,
            width = math.ceil(args.width * 0.7),
            shape = utils.prrect(args.border_radius, true, false, false, true),
            child = wibox.widget {
                icon {
                    icon = beautiful.wifi_icon,
                    colour = "#000000",
                    size = icon_size
                },
                ssid_text,
                layout = wibox.layout.flex.horizontal
            }
        }, function(self)
            if not self:toggle() then
                network:turn_off()
            else
                network:turn_on()
            end
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

    network:connect_signal("connection", function(_, ssid)
        ssid_text.markup = utils.coloured_text(ssid, "#000000")
    end)

    network:connect_signal("status", function(_, status)
        wifi_toggle.children[1].status = status == "connected"
        if status ~= "connected" then
            ssid_text.markup = utils.coloured_text("None", "#000000")
        end
    end)

    return wifi_toggle, submenu
end
