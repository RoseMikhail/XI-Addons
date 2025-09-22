_addon.name = 'RoseHudHider'
_addon.author = 'Rosemikhail'
_addon.version = '0.1'
_addon.commands = {'rhh'}

local is_hidden_by_key = false

-- Bind on load
windower.register_event('load', function()
    windower.add_to_chat(123, "Addon loaded!!!??")
    windower.send_command('bind f4 rhh toggle_display')
end)

-- Unbind on unload
windower.register_event('unload', function()
    windower.add_to_chat(123, "Addon unloaded!!!")
    windower.send_command('unbind f4')
end)

-- hide the addons
local function hide()
    windower.send_command('ffxidb p 10000 10000') -- Do it this way to prevent crashes lol
    windower.send_command('unload timers')
    windower.send_command('lua unload debuffed')
    windower.send_command('lua unload distanceplus')
    windower.send_command('lua unload enemybar2')
    windower.send_command('lua unload equipviewer')
    --windower.send_command('lua unload tparty')
    windower.send_command('lua unload giltrackerr')
    windower.send_command('lua unload muffincounter')
    windower.send_command('lua unload barfiller')
end

-- show the addons
local function show()
    windower.send_command('ffxidb p 1553 641') -- Do it this way to prevent crashes lol
    windower.send_command('load timers')
    windower.send_command('lua load debuffed')
    windower.send_command('lua load distanceplus')
    windower.send_command('lua load enemybar2')
    windower.send_command('lua load equipviewer')
    --windower.send_command('lua load tparty')
    windower.send_command('lua load giltracker')
    windower.send_command('lua load muffincounter')
    windower.send_command('lua load barfiller')
end

-- Handle the toggle command
windower.register_event('addon command', function(cmd)
    if cmd == 'toggle_display' then
        if is_hidden_by_key == false then
            is_hidden_by_key = true
            hide()
        else
            is_hidden_by_key = false
            show()
        end
    end
end)