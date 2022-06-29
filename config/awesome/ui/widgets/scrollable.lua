local setmetatable = setmetatable
local base = require("wibox.widget.base")
local gears = require("gears")
local gtable = gears.table

local naughty = require("naughty")

local scrollable = { mt = {} }

function scrollable:fit(context, width, height)
    naughty.notify({ message = tostring(width) .. " " .. tostring(height) })
    return self._private.width, self._private.height
end

function scrollable:draw(context, cr, width, height)
    cr:set_source(gears.color("#ffffff"))
    cr:rectangle(0, 0, width, height)
    cr:fill()
end



function scrollable.new(args)
    args = args or {}
    
    return base.make_widget_declarative(args)
    --[[local w = base.make_widget(nil, nil, { enable_properties = true })

    w._private.width = args.width or 100
    w._private.height = args.height or 100
    
    gtable.crush(w, scrollable, true)

    return w]]--
end

function scrollable.mt:__call(...)
    return scrollable.new(...)
end

return setmetatable(scrollable, scrollable.mt)
