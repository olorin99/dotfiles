local awful = require("awful")

local naughty = require("naughty")

local brightness_script = [[
    sh -c "
    brightnessctl i | grep -oP '\(\K[^%\)]+'
"]]


awful.spawn.easy_async_with_shell("sh -c 'OUT=\"$(find /sys/class/backlight/?*/brightness)\" && (echo \"$OUT\" | head -1) || false'", function(brightness_file, _, _, exit_code)
    if not (exit_code == 0) then
        return
    end

    brightness_file = string.gsub(brightness_file, "\n", "")
    
    -- run on start up to get current brightness levels
    awful.spawn.easy_async_with_shell(brightness_script, function(line, _, _, exit_code)
        awesome.emit_signal("signals::brightness", math.floor(tonumber(line)))
    end)

    -- run whenever brightness file changes
    awful.spawn.easy_async_with_shell("ps x | grep \"inotifywait -e modify " .. brightness_file .. "\" | grep -v grep | awk '{print $1}' | xargs kill", function()
        awful.spawn.with_line_callback("sh -c \"while (inotifywait -e modify " .. brightness_file .. " -qq) do echo; done\"", {
            stdout = function(_)
                awful.spawn.with_line_callback(brightness_script, {
                    stdout = function(line)
                        awesome.emit_signal("signals::brightness", math.floor(tonumber(line)))
                    end
                })
            end
        })
    end)
end)
