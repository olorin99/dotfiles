local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local utils = {}

utils.utf8 = function(codepoint)
    return utf8.char(tonumber(codepoint, 16))
end

utils.pixels_to_point = function(pixels)
    return math.floor(pixels / beautiful.xresources.get_dpi() * 72)
end

utils.point_to_pixels = function(point)
    return math.ceil(point * beautiful.xresources.get_dpi() * 72)
end

utils.coloured_text = function(text, colour)
    return "<span foreground=\"" .. colour .. "\">" .. text .. "</span>"
end

utils.split = function(str, delim)
    local sections = {}
    for v in str:gmatch("([^" .. delim .. "]+)") do
        table.insert(sections, v)
    end
    return sections
end

utils.rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

utils.prrect = function(radius, tl, tr, br, bl)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
    end
end

utils.desktop_entry = function(path)
    local cmd = ""
    local icon = ""

    for line in io.lines(path) do
        local a, b = line:find("Exec=")
        if b ~= nil then
            cmd = string.sub(line, b + 1)
        end
        local c, d = line:find("Icon=")
        if d ~= nil then
            icon = string.sub(line, d + 1)
        end
    end

    return { class = "", icon = icon, cmd = function() awful.spawn(cmd) end }
end

utils.snap = function(c, edge, geometry)
    
    local screenGeometry = screen[c.screen].geometry
    local screenExtent = screen[c.screen].workarea
    local area = {
        xMin = screenExtent.x,
        xMax = screenExtent.x + screenExtent.width,
        yMin = screenExtent.y,
        yMax = screenExtent.y + screenExtent.height
    }

    local cg = geometry or c:geometry()
    local border = c.border_width
    --local cs = c:struts()
    --cs['left'] = 0
    --cs['top'] = 0
    --cs['right'] = 0
    --cs['bottom'] = 0
    if edge ~= nil then
--        c:struts(cs)
    end

    if edge == "right" then
        cg.width = screenExtent.width / 2 - 2 * border
        cg.height = screenExtent.height
        cg.x = area.xMax - cg.width
        cg.y = area.yMin
    elseif edge == "left" then
        cg.width = screenExtent.width / 2 - 2 * border
        cg.height = screenExtent.height
        cg.x = area.xMin
        cg.y = area.yMin
    elseif edge == "top" then
        cg.width = screenExtent.width
        cg.height = screenExtent.height / 2 - 2 * border
        cg.x = area.xMin
        cg.y = area.yMin
    elseif edge == "bottom" then
        cg.width = screenExtent.width
        cg.height = screenExtent.height / 2 - 2 * border
        cg.x = area.xMin
        cg.y = area.yMin + cg.height
    elseif edge == "topright" then
        cg.width = screenExtent.width / 2 - 2 * border
        cg.height = screenExtent.height / 2 - 2 * border
        cg.x = area.xMin + cg.width
        cg.y = area.yMin
    elseif edge == "topleft" then
        cg.width = screenExtent.width / 2 - 2 * border
        cg.height = screenExtent.height / 2 - 2 * border
        cg.x = area.xMin
        cg.y = area.yMin
    elseif edge == "bottomright" then
        cg.width = screenExtent.width / 2 - 2 * border
        cg.height = screenExtent.height / 2 - 2 * border
        cg.x = area.xMin + cg.width
        cg.y = area.yMin + cg.height
    elseif edge == "bottomleft" then
        cg.width = screenExtent.width / 2 - 2 * border
        cg.height = screenExtent.height / 2 - 2 * border
        cg.x = area.xMin
        cg.y = area.yMin + cg.height
    elseif edge == "center" then
        awful.placement.centered(c)
        return
    elseif edge == nil then
        --c:struts(cs)
        c:geometry(cg)
        return
    end
    
    --c.floating = true
    if c.maximized then c.maximized = false end
    c:geometry(cg)
    awful.placement.no_offscreen(c)
end

return utils
