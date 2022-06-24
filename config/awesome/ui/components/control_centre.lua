local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")
local button = require("ui.widgets.button")
local toggle = require("ui.widgets.toggle")
local icon = require("ui.widgets.icon")

local naughty = require("naughty")

-- toggles

-- wifi toggle
local wifi_toggle = toggle({
    size = dpi(50),
    child = wibox.widget {
        icon{ icon = beautiful.wifi_icon, colour = "#000000", size = dpi(25) },
        wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("None", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }
}, function(self)
    if not self:toggle() then
        awful.spawn("nmcli radio wifi off")
    else
        awful.spawn("nmcli radio wifi on")
    end
end,
function(self)
    awesome.emit_signal("signals::network_scan_start")
end)

awesome.connect_signal("signals::network", function(status, ssid)
    wifi_toggle.all_children[3].markup = utils.coloured_text(ssid, "#000000")
    wifi_toggle.status = status
end)

-- sound toggle
local sounds_toggle = toggle({
    size = dpi(50),
    child = wibox.widget {
        icon{ icon = beautiful.volume_icon, colour = "#000000", size = dpi(25) },
        wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("None", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }
}, function()
    awesome.emit_signal("signals::mute")
end)

awesome.connect_signal("signals::mute", function()
    if not sounds_toggle:toggle() then
        sounds_toggle.all_children[2].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
        sounds_toggle.all_children[3].markup = utils.coloured_text("Mute", "#000000")
    else
        sounds_toggle.all_children[2].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
        sounds_toggle.all_children[3].markup = utils.coloured_text("Sound", "#000000")
    end
end)

-- bluetooth toggle
local bluetooth_toggle = toggle({
    size = dpi(50),
    child = wibox.widget {
        icon{ icon = beautiful.bluetooth_icon, colour = "#000000", size = dpi(25) },
        wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("None", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }
}, function(self)
    if not self:toggle() then
        awful.spawn("bluetoothctl power off")
    else
        awful.spawn("bluetoothctl power on")
    end
end)

-- screenshot button
local screenshot_button = button({ 
    size = dpi(50),
    bg = beautiful.colours.blue,
    shape = utils.rrect(dpi(8)),
    child = wibox.widget {
        icon{ icon = utils.coloured_text(beautiful.screenshot_icon, "#000000"), size = dpi(25) },
        {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("Screenshot", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }}, 
    function(self)
        self.bg = beautiful.panel1
        gears.timer({
            timeout = 3,
            single_shot = true,
            callback = function()
                self.bg = beautiful.colours.blue
            end
        }):again()
        awful.spawn.with_shell("maim " .. user.home .. "/Pictures/screenshots/$(date +%s).png")
end)

local toggles = wibox.widget {
    wifi_toggle,
    sounds_toggle,
    bluetooth_toggle,
    screenshot_button,
    spacing = dpi(5),
    forced_num_cols = 2,
    homogeneous = true,
    expand = true,
    layout = wibox.layout.grid
}

-- submenus

local available_networks = wibox.widget {
    visible = false,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
    widget = wibox.container.background
}

available_networks:connect_signal("mouse::leave", function()
    available_networks.visible = false
    toggles.visible = true
end)

awesome.connect_signal("signals::network_scan_finished", function(networks)
    available_networks:reset()
    for _, network in ipairs(networks) do
        available_networks:add(wibox.widget {
            {
                text = network,
                widget = wibox.widget.textbox
            },
            --TODO: textinput widget to get password
            button({ size = dpi(30), bg = beautiful.colours.blue, shape = utils.rrect(dpi(8)) }, function() 
                awful.spawn("nmcli dev wifi connect " .. network)
            end),
            layout = wibox.layout.fixed.horizontal
        })
    end
    toggles.visible = false
    available_networks.visible = true
end)




return function(args)

    local control = wibox.widget {
        toggles,
        available_networks,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    return control
end