local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

local button = require("ui.widgets.button")
local toggle = require("ui.widgets.toggle")

local naughty = require("naughty")

local network_local = wibox.widget {
    max_size = dpi(10),
    layout = wibox.container.scroll.vertical,
    widget = wibox.container.background
}

local network_button = toggle(dpi(50), { enabled = beautiful.colours.blue, shape = utils.rrect(dpi(8)) }, 
function(self)
    self.state = not self.state
    if not self.state then
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

            naughty.notify({ text = ssid })
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


local sounds_button = toggle(dpi(50), { enabled = beautiful.colours.blue, text = utils.coloured_text("Sound", "#000000"), shape = utils.rrect(dpi(8)) }, function(self)
    awesome.emit_signal("signals::mute")
end)

awesome.connect_signal("signals::mute", function()
    sounds_button.state = not sounds_button.state
    if not sounds_button.state then
        sounds_button.children[1].markup = utils.coloured_text("Mute", "#000000")
        sounds_button.bg = beautiful.panel1
    else
        sounds_button.children[1].markup = utils.coloured_text("Sound", "#000000")
        sounds_button.bg = beautiful.colours.blue
    end
        
end)

return function(args)

    local control = wibox.widget {
        {
            network_button,
            sounds_button,
            spacing = dpi(5),
            forced_num_cols = 2,
            forced_num_rows = 2,
            homogeneous = true,
            expand = true,
            layout = wibox.layout.grid
        },
        network_local,
        layout = wibox.layout.stack
    }

    return control
end
