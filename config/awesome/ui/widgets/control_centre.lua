local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

local button = require("ui.widgets.button")

local naughty = require("naughty")

local network_local = wibox.widget {
    max_size = dpi(10),
    layout = wibox.container.scroll.vertical,
    widget = wibox.container.background
}

local network_button = button(dpi(50), { bg = beautiful.colours.blue, shape = utils.rrect(dpi(8)) }, 
function(self)
    if self.status then
        awful.spawn("nmcli radio wifi off")
        self.bg = beautiful.panel1
    else
        awful.spawn("nmcli radio wifi on")
        self.bg = beautiful.colours.blue
    end
end,
function(self) --TODO: open menu to choose networks
    awful.spawn.easy_async("nmcli device wifi", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            return
        end

        network_local:reset()

        local f, l = stdout:find("([^\r\n]*)[\r\n]")
        local first = stdout:sub(1, l)
        local a, b = first:find(" SSID")
        local c, d = first:find("MODE")

        local lines = stdout:sub(l)
        for line in lines:gmatch("([^\r\n]*)[\r\n]") do
            local ssid = line:sub(a, c - 1)

            local w = wibox.widget {
                text = ssid,
                widget = wibox.widget.textbox
            }
            network_local:add(w)
        end
    end)
end)

awesome.connect_signal("signals::network", function(status, ssid)
    network_button.children[1].markup = utils.coloured_text(ssid, "#000000")
    network_button.status = status
end)


local sounds_button = button(dpi(50), { bg = beautiful.colours.blue, text = utils.coloured_text("Sound", "#000000"), shape = utils.rrect(dpi(8)) }, function(self)
    self.mute = not self.mute
    awful.spawn("amixer set Master 1+ toggle")
    if self.mute then
        self.children[1].markup = utils.coloured_text("Mute", "#000000")
        self.bg = beautiful.panel1
    else
        self.children[1].markup = utils.coloured_text("Sound", "#000000")
        self.bg = beautiful.colours.blue
    end
end)

return function(args)

    local control = wibox.widget {
        {
            network_button,
            sounds_button,
            spacing = dpi(5),
            layout = wibox.layout.flex.horizontal
        },
        network_local,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    return control
end
