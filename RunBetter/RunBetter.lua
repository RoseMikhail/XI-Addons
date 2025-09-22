_addon.name = 'RunBetter'
_addon.author = 'Rose'
_addon.version = '1.0'
_addon.language = 'english'
_addon.commands = {'runbetter', 'rb'}

-- Command usage: "<rb/runbetter> <on/off/auto>".
-- "auto" will automatically adjust the graphics settings when you start and finish Domain Invasion.
-- If you want to tweak what the defaults are and what they change to, just edit improve_performanace and restore_graphics.

-- TODO: Someday the config plugin will surely give me commands to mess with Effects filters and PC Armor Display.
-- Or maybe I'll figure out how to access that stuff myself, but that would assume I have more than a peanut in this head.

require('coroutine')
config = require('config')

defaults = {}
defaults.auto = false
settings = config.load(defaults)

function improve_performanace()
    windower.chat.input("/localsettings shadows off")
    windower.chat.input("/localsettings blureffect off")
    windower.chat.input("/localsettings charanum 25")
    windower.chat.input("/localsettings distance 0")
    windower.chat.input("/hidetrust on")
    --windower.chat.input("/names off")
end

function restore_graphics()
    windower.chat.input("/localsettings shadows normal")
    windower.chat.input("/localsettings blureffect on")
    windower.chat.input("/localsettings charanum 50")
    windower.chat.input("/localsettings distance 10")
    windower.chat.input("//config ClippingPlane 5") -- Only if config is installed
    windower.chat.input("/hidetrust off")
    --windower.chat.input("/names on")  
end

-- Can be expanded to support other similar buffs, if necessary
-- For testing purposes, 40 is Protect, 627 is Mobilisation and 603 is elvorseal

function does_player_have_elvorseal()
    buffs = windower.ffxi.get_player().buffs
    for i=1,#buffs do
        if buffs[i] == 603 then -- elvorseal
            return true
        end
    end
    
    return false
end

function toggle_auto()
    if settings.auto == false then
        settings.auto = true
        windower.add_to_chat(200, 'Automatic mode enabled.' )
        if does_player_have_elvorseal() == true then
            windower.add_to_chat(200, 'Elvorseal detected: Lowering graphics.' )
            improve_performanace()
        elseif does_player_have_elvorseal() == false then
            windower.add_to_chat(200, 'No elvorseal detected: Restoring graphics.' )
            restore_graphics()
        end
    elseif settings.auto == true then
        settings.auto = false
        windower.add_to_chat(200, 'Automatic mode disabled.' )
    end
    settings:save('all')
end

function disable_auto()
    if settings.auto == true then
        windower.add_to_chat(167, 'Automatic mode disabled.' )
        settings.auto = false
        settings:save('all')
    end
end

-- Using Mobilisation and waiting ten seconds is just to cope with not being able to post commands in the chat during dialogue and loading.
function mobilisation_added(buff_id)
    if buff_id == 627 and settings.auto == true then -- mobilisation
        windower.add_to_chat(200, 'Mobilisation Added: Lowering graphics in ten seconds.')
        coroutine.sleep (10)
        improve_performanace()
    end
end

function elvorseal_removed(buff_id)
    if buff_id == 603 and settings.auto == true then -- elvorseal
        windower.add_to_chat(200, 'Elvorseal Removed: Restoring graphics.')
        restore_graphics()
    end
end

function command(...)
    if #arg > 1 then
        windower.add_to_chat(167, 'Invalid command.')
    elseif #arg == 1 and arg[1]:lower() == 'on' then
        disable_auto()
        improve_performanace()
        windower.add_to_chat(200, 'This game should now run better. I also recommend turning Effects filters on and setting PC Armor Display to static for an even greater boost to FPS.' )
    elseif #arg == 1 and arg[1]:lower() == 'off' then
        disable_auto()
        restore_graphics()
        windower.add_to_chat(200, 'This game should now look prettier. I also recommend turning Effects filters off and PC Armor Display to Normal.' )
    elseif #arg == 1 and arg[1]:lower() == 'auto' then
        toggle_auto()
    else
        windower.add_to_chat(167, 'Invalid command.')
    end
end

windower.register_event('addon command', command)
windower.register_event('gain buff', mobilisation_added)
windower.register_event('lose buff', elvorseal_removed)