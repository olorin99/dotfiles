
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

local battery = require("ui.widgets.battery")
local brightness = require("ui.widgets.brightness")
local button = require("ui.widgets.button")
local volume = require("ui.widgets.volume")
local clock = require("ui.widgets.clock")

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({}, 2, function(c)
        require("naughty").notify({
            text = tostring(c.class)
        })
        local cmd = "/proc/" .. tostring(c.pid) .. "/exe"
        awful.spawn(cmd)
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end)
)

function create_icon(args)

    local c = args.client or "invalid"
    local cmd = args.cmd or function () end

    local icon = wibox.widget {
        {
            id = "icon_role",
            text = c,
            widget = wibox.widget.textbox
        },
        forced_width = dpi(48),
        forced_height = dpi(48),
        widget = wibox.container.background
    }

    return icon
end

awful.screen.connect_for_each_screen(function(s)
    
   local tasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,--function() return true end, --awful.widget.tasklist.filter.currenttags,
        --[[source = function()
            local cls = client.get()

            local result = {}
            local class_seen = {}
            for _, c in ipairs(cls) do
                if awful.widget.tasklist.filter.currenttags(c, s) then
                    if not class_seen[c.class] then
                        class_seen[c.class] = true
                        table.insert(result, c)
                    end
                end
            end
            return result
        end,]]--
        buttons = tasklist_buttons,
        layout = wibox.layout.fixed.horiztonal,
        widget_template = {
            {
                {
                    id = "icon_role",
                    widget = wibox.widget.imagebox
                },
                widget = wibox.container.background,
                forced_width = dpi(48),
                forced_height = dpi(48)
            },
            left = dpi(3),
            right = dpi(3),
            widget = wibox.container.margin,
            create_callback = function(self, c, index, objects)
                local tooltop = awful.tooltip {
                    objects = { self },
                    timer_function = function()
                        return c.name
                    end
                }
            end
        }
    }
    
    local dock = wibox.widget {
        {
            battery(dpi(48), "north", true),
            brightness({ width = dpi(48) }),
            volume({ width = dpi(48)}),
            tasklist,
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal
        },
        margins = dpi(10),
        widget = wibox.container.margin
    }

    s.dock = awful.popup({
        screen = s,
        visible = true,
        ontop = true,
        placement = awful.placement.bottom,
        bg = beautiful.panel,
        shape = utils.rrect(beautiful.rounded_corners),
        widget = dock,
        type = "dock"
    })
    --awful.placement.bottom(s.dock, { margins = beautiful.useless_gap })

    s.dock_trigger = wibox {
        screen = s,
        bg = "#000000",
        widget = wibox.container.background,
        ontop = true,
        opacity = 0,
        visible = true,
        height = dpi(10),
        type = "dock",
    }
    awful.placement.bottom(s.dock_trigger)

    local hide_timeout = gears.timer({
        timeout = 5,
        single_shot = true,
        callback = function()
            s.dock.visible = false
        end
    })

    hide_timeout:again()

    s.dock:connect_signal("property::width", function()
        s.dock_trigger.width = s.dock.width
        --awful.placement.bottom(s.dock, { margins = beautiful.useless_gap })
        awful.placement.bottom(s.dock_trigger)
    end)

    s.dock:connect_signal("mouse::leave", function()
        hide_timeout:again()
    end)

    s.dock:connect_signal("mouse::enter", function()
        hide_timeout:stop()
    end)

    s.dock_trigger:connect_signal("mouse::leave", function()
        hide_timeout:again()
    end)

    s.dock_trigger:connect_signal("mouse::enter", function()
        s.dock.visible = true
        hide_timeout:stop()
    end)

end)