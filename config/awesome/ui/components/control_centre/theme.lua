local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local toggle = require("ui.widgets.toggle")
local button = require("ui.widgets.button")
local icon = require("ui.widgets.icon")

return function(args)
    local icon_size = args.height * 0.5

    local submenu = wibox.widget {
        button({
            width = args.width,
            height = args.height,
            shape = utils.rrect(dpi(8)),
    }
end
