
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local menubar = require("menubar")
local rubato = require("modules.rubato")

local battery = require("ui.components.battery")
local button = require("ui.widgets.button")

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
    
    local class = args.class or "invalid"
    local cmd = function() awful.spawn.with_shell(args.Exec) end or function () end
    local name = args.Name or "application"

    local icon = wibox.widget {
        {
            valign = "center",
            halign = "center",
            image = menubar.utils.lookup_icon(args.Icon),
            widget = wibox.widget.imagebox
        },
        forced_width = dpi(48),
        forced_height = dpi(48),
        bg = "#00000000",
        shape = utils.rrect(dpi(2)),
        widget = wibox.container.background
    }
    --TODO: focus indicator, tooltip

    local tooltip = awful.tooltip {
        objects = { icon },
        timer_function = function()
            return name
        end
    }

    icon:buttons(gears.table.join(
        awful.button({ }, 1, cmd), --TODO: focus or create new
        awful.button({ }, 2, cmd),
        awful.button({ }, 3, cmd) --TODO: show preview
    ))

    icon:connect_signal("mouse::enter", function()
        icon.bg = beautiful.colours.overlay1
    end)

    icon:connect_signal("mouse::leave", function()
        icon.bg = "#00000000"
    end)

    return icon
end

function create_pinned(args)
    pinned = wibox.widget {
        layout = wibox.layout.fixed.horizontal
    }

    for _, p in ipairs(args.pinned_apps) do
        pinned:add(create_icon(p))
    end
    return pinned
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
            create_pinned({ pinned_apps = user.pinned_apps }),
            {              
                orientation = "vertical",
                forced_height = dpi(48),
                forced_width = dpi(3),
                thickness = dpi(1),
                widget = wibox.widget.separator
            },
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
        bg = beautiful.bg_panel,
        shape = utils.rrect(beautiful.rounded_corners),
        widget = dock,
        type = "dock"
    })
    --awful.placement.bottom(s.dock, { margins = beautiful.useless_gap })

    s.dock_trigger = wibox {
        screen = s,
        bg = "#00000000",
        widget = wibox.container.background,
        ontop = true,
        opacity = 0,
        visible = true,
        height = dpi(10),
        type = "dock",
    }
    awful.placement.bottom(s.dock_trigger)

    local y = s.geometry.height
    local ya = s.geometry.height - dpi(68)
    local animation = rubato.timed {
        intro = 0.1,
        outro = 0.1,
        duration = 0.3,
        pos = ya,
        rate = 60,
        easing = rubato.quadratic,
        subscribed = function(pos)
            s.dock.y = pos
        end
    }

    local hide_timeout = gears.timer({
        timeout = 5,
        single_shot = true,
        callback = function()
            animation.target = y
            gears.timer {
                timeout = 0.4,
                call_now = false,
                single_shot = true,
                callback = function()
                    s.dock.visible = false
                end
            }:again()
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
        animation.target = ya
        hide_timeout:stop()
    end)

end)


function reload_dock()
    for s in screen do
        s.dock.widget.children[1].children[1] = create_pinned({ pinned_apps = user.pinned_apps })
    end
end
