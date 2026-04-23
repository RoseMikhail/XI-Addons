_addon.name = 'SettingTheStage'
_addon.author = 'Rose'
_addon.version = '1.0'
_addon.language = 'english'
_addon.commands = {'sts'}

local packets = require('packets')
local config = require('config')
local texts = require('texts')
local resources = require('resources')

-- Config
local defaults = {}
defaults.timer_formatting = {
    pos = {x = 0, y = 0},
    bg = {alpha = 0},
    flags = {draggable = true, right = false},
    text = {font = "Arial", size = 20, stroke = {width = 1}},
}
defaults.party_warning = false
local settings = config.load(defaults)

-- Timer variables
local timer = texts.new(settings.timer_formatting)
local timer_active = false
local start_time = nil
local elapsed = nil
local warned = false
local setting_the_stage = false

-- Enemy update variables
local engaged = false
local dead = false

function start_timer()
    timer_active = true
    start_time = os.time()
    warned = false
    setting_the_stage = false
    timer:color(255, 255, 255)
    timer:text("")
    timer:visible(true)
end

function stop_timer()
    timer_active = false
    warned = false
    setting_the_stage = false
    timer:visible(false)
end

windower.register_event('incoming chunk', function(id, data)
    -- Look for when Skomora or Triboulex aggro so that the timer can be started
    if id == 0x00E then -- NPC Update
        local packet = packets.parse('incoming', data)
        local mob_index = packet.Index
        local mob_status = packet.Status

        local mob = windower.ffxi.get_mob_by_index(mob_index)
        
        if mob then
            local mob_name = mob.name -- Many errors if we don't check that mob exists first

            if mob_name == "Skomora" or mob_name == "Triboulex" then
                if mob_status == 1 and not engaged then
                    engaged = true
                    dead = false
                    start_timer()
                elseif (mob_status == 2 or mob_status == 3) and not dead then
                    -- Could potentially instead check 0x029 for the "falls to the ground" action message.
                    engaged = false
                    dead = true
                    if setting_the_stage then
                        windower.add_to_chat(123, "Nice cock.")
                    end
                    stop_timer()
                end
            end
        end
    end

    -- Look for Setting The Stage being readied so that the timer can be reset.
    if id == 0x028 then -- Action
        local packet = packets.parse('incoming', data)
        local mob_id = packet.Actor
        local param = packet["Param"]

        local mob = windower.ffxi.get_mob_by_id(mob_id)
        local action = resources.monster_abilities[param]

        if mob and action then
            local mob_name = mob.name
            local action_name = action.en

            if (mob_name == "Skomora" or mob_name == "Triboulex") and action_name == "Setting the Stage" then
                start_timer()
            end
        end
    end

    -- Reset if we warp out
    if id == 0x00A or id == 0x00B then -- Zone Update/Response when I have left - maximum safety I guess
        engaged = false
        dead = false
        stop_timer()
    end
end)

windower.register_event('prerender', function(...)
    if timer_active then
        elapsed = 180 - (os.time() - start_time)

        -- 30s remaining warning
        if not warned and elapsed <= 30 then
            if settings.party_warning then
                windower.send_command('input /p Setting the Stage in 30s! <call21>')
            end
            timer:color(255, 0, 0)
            warned = true
        end

        -- Timer has ran out. Variable to prevent updating the text box any more than I need to.
        if elapsed <= 0 then
            if not setting_the_stage then
                timer:text("Setting the Stage")
                setting_the_stage = true
            end
        else
            local minutes = math.floor(elapsed / 60) -- This sheds the decimels, so we'll need to get that back as seconds
            local seconds = elapsed % 60 -- We find the remainder seconds via modulo

            timer:text(string.format("%02d:%02d", minutes, seconds))
        end
    end
end)

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if type == 2 then
        -- For some reason, pos() just returns one value. I'm sure I just used it wrong, but it's 3am so...
        settings.timer_formatting.pos = {x = timer:pos_x(), y = timer:pos_y()}
        settings:save('all')
    end
end)

windower.register_event('addon command', function(...)
    if #arg > 1 then
        windower.add_to_chat(167, 'Invalid command.')
    elseif #arg == 1 and arg[1]:lower() == 'start' then
        start_timer()
    elseif #arg == 1 and arg[1]:lower() == 'stop' then
        stop_timer()
    elseif #arg == 1 and arg[1]:lower() == 'warning' then
        settings.party_warning = not settings.party_warning

        if settings.party_warning then
            windower.add_to_chat(123, 'Party warning enabled.')
        else
            windower.add_to_chat(123, 'Party warning disabled.')
        end

        settings:save('all')
    else
        windower.add_to_chat(123, 'Invalid command.')
    end
end)