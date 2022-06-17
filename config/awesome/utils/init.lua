local awful = require("awful")
local gears = require("gears")

local utils = {}

utils.coloured_text = function(text, colour)
    return "<span foreground=\"" .. colour .. "\">" .. text .. "</span>"
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
