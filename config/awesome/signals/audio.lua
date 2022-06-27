local awful = require("awful")

awful.spawn.easy_async("sh -c \"awk -F'[][]' '/Left:/ { print $2 }' <(amixer sget Master)\"", function(stdout, _, _, exit_code)
    if not (exit_code == 0) then
        return
    end

    local volume = string.gsub(stdout, "%%", "")
    volume = string.gsub(volume, "\n", "")
    awesome.emit_signal("audio::volume", tonumber(volume))
end)

awful.spawn.easy_async_with_shell("ps x | grep \"pactl subscribe\" | grep -v grep | awk '{print $1}' | xargs kill", function()
    awful.spawn.with_line_callback("sh -c \"pactl subscribe | grep --line-buffered 'sink'\"", {
        stdout = function(out)
        
            awful.spawn.easy_async("sh -c \"awk -F'[][]' '/Left:/ { print $2 }' <(amixer sget Master)\"", function(out, _, _, exit_code)
    
                local volume = string.gsub(out, "%%", "")
                volume = string.gsub(volume, "\n", "")
                awesome.emit_signal("audio::volume", tonumber(volume))
            end)
    
        end
    })
end)

awesome.connect_signal("audio::mute", function()
    awful.spawn("amixer set Master mute")
end)

awesome.connect_signal("audio::unmute", function()
    awful.spawn("amixer set Master unmute")
end)

awesome.connect_signal("audio::toggle", function()
    awful.spawn("amixer set Master 1+ toggle")
end)

awesome.connect_signal("audio::set", function(volume)
    awful.spawn("amixer set Master " .. tostring(volume) .. "%")
end)

awesome.connect_signal("audio::increment", function()
    awful.spawn("amixer set Master 10%+")
end)

awesome.connect_signal("audio::decrement", function()
    awful.spawn("amixer set Master 10%-")
end)
