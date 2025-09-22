_addon.name = 'RoseHudHider'
_addon.author = 'Rosemikhail'
_addon.version = '0.1'

local is_hidden_by_key = false

-- hide the addons
local function hide()
    windower.send_command('ffxidb p 10000 10000') -- Do it this way to prevent crashes lol
    windower.send_command('unload timers')
    windower.send_command('lua unload debuffed')
    windower.send_command('lua unload distanceplus')
    windower.send_command('lua unload enemybar2kyane')
    windower.send_command('lua unload xivbarKyaneCustom')
    --windower.send_command('lua unload tparty')
    windower.send_command('lua unload Sch-Hud-Reworked')
    windower.send_command('lua unload xivparty')
    windower.send_command('lua unload pettp')
end

-- show the addons
local function show()
    windower.send_command('ffxidb p 1678 1177') -- Do it this way to prevent crashes lol
    windower.send_command('load timers')
    windower.send_command('lua load debuffed')
    windower.send_command('lua load distanceplus')
    windower.send_command('lua load enemybar2kyane')
    windower.send_command('lua load xivbarKyaneCustom')
    --windower.send_command('lua load tparty')
    windower.send_command('lua load Sch-Hud-Reworked')
    windower.send_command('lua load xivparty')
    windower.send_command('lua load pettp')
end

-- TOGGLE ON SCROLL LOCK
windower.register_event('keyboard', function(dik, down, _flags, _blocked)
    toggle_display_if_hide_key_is_pressed(dik, down)
end)

function toggle_display_if_hide_key_is_pressed(key_pressed, key_down)
    if (key_pressed == 70) and (key_down) and (is_hidden_by_key) then
        is_hidden_by_key = false
        show()
    elseif (key_pressed == 70) and (key_down) and (not is_hidden_by_key) then
        is_hidden_by_key = true
        hide()
    end
end