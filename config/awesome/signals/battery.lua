local awful = require("awful")

awful.spawn.easy_async_with_shell("sh -c 'OUT=\"$(find /sys/class/power_supply/BAT?/capacity)\" && (echo \"$OUT\" | head -1) || false' ", function(battery_file, _, _, exit_code)
    if not (exit_code == 0) then
        return
    end

    awful.widget.watch("cat "..battery_file, 30, function(_, stdout)
        awesome.emit_signal("signals::battery", tonumber(stdout))
    end)
end)
