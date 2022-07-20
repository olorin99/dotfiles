local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lgi = require("lgi")
local gio = lgi.Gio
local glib = lgi.GLib

local utils = {}


utils.directory = function(path, callback, recursive)
    if not path then
        return
    end

    local result = {}

    local function enumerator(path)
        local gfile = gio.File.new_for_path(path)
        gfile:enumerate_children_async(
            "standard::name,standard::type,access::can-read",
            gio.FileQueryInfoFlags.NONE,
            0,
            nil,
            function(file, task, c)
                local enum, error = file:enumerate_children_finish(task)
                if enum == nil or error ~= nil then
                    print("Failed looping directory " .. path .. " " .. tostring(error))
                    callback(nil)
                    return
                end

                enum:next_files_async(99999, 0, nil, function(file_enum, task2, c)
                    local files, error = file_enum:next_files_finish(task2)
                    if files == nil or error ~= nil then
                        print("Failed")
                        callback(nil)
                        return
                    end

                    for _, file in ipairs(files) do
                        local file_child = enum:get_child(file)
                        local file_type = file:get_file_type()
                        local readable = file:get_attribute_boolean("access::can-read")
                        if file_type == "REGULAR" and readable then
                            local path = file_child:get_path()
                            if path ~= nil then
                                table.insert(result, path)
                            end
                        elseif file_type == "DIRECTORY" and recursive then
                            enumerator(file_child:get_path())
                        end
                    end

                    enum:close_async(0, nil)
                    callback(result)
                end)
            end)
    end

    enumerator(path)
end

utils.save_file = function(path, text, callback, is_retry)
    local gfile = gio.File.new_for_path(path)
    gfile:open_readwrite_async(glib.PRIORITY_DEFAULT, nil, function(_, io_stream_result)
        local io_stream = gfile:open_readwrite_finish(io_stream_result)
        io_stream:seek(0, glib.SeekType.SET, nil)
        local file = io_stream:get_output_stream()
        file:write_all_async(text, glib.PRIORITY_DEFAULT, nil, function(_, write_result)
            local length_written = file:write_all_finish(write_result)
            file:truncate(length_written, nil)
            file:close_async(glib.PRIORITY_DEFAULT, nil, function(_, file_close_result)
                io_stream:close_async(glib.PRIORITY_DEFAULT, nil, function(_, stream_close_result)
                    if callback then
                        callback(true)
                    end
                end, nil)
            end, nil)
        end, nil)
    end)
end

utils.read_file = function(path, callback)
    local gfile = gio.File.new_for_path(path)
    gfile:load_contents_async(nil, function(file, task, c)
        local content = gfile:load_contents_finish(task)
        if content == nil then
            print("Failed read " .. path)
            callback(nil)
        else
            callback(content)
        end
    end)
end









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
    local cmd = nil
    local icon = nil
    local name = nil

    for line in io.lines(path) do
        if cmd == nil then
            local a, b = line:find("Exec=")
            if b ~= nil then
                cmd = string.sub(line, b + 1)
            end
        end
        if icon == nil then
            local c, d = line:find("Icon=")
            if d ~= nil then
                icon = string.sub(line, d + 1)
            end
        end
        if name == nil then
            local e, f = line:find("Name=")
            if f ~= nil then
                name = string.sub(line, f + 1)
            end
        end
    end

    return { class = "", name = name, icon = icon, cmd = function() awful.spawn(cmd) end, cmd_str = cmd }
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
