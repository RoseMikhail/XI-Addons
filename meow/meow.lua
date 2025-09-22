_addon.name = 'Meow'
_addon.author = 'Rose'
_addon.version = '1.0'
_addon.language = 'english'
_addon.commands = {'meow'}

-- Command usage: "//meow <on/off>".

-- Require
config = require('config')
packets = require('packets')
resources = require('resources')

-- Config
defaults = {}
defaults.meow = false
settings = config.load(defaults)

-- For Aydin check
math.randomseed(os.time())

windower.register_event('addon command', function(...) 
    if #arg > 1 then
        windower.add_to_chat(167, 'Invalid command.')
    elseif #arg == 1 and arg[1]:lower() == 'on' then
        windower.add_to_chat(200, 'I am so sorry. Be aware that this will not respect your in-game blacklist.' )
        settings.meow = true
        settings:save('all')
    elseif #arg == 1 and arg[1]:lower() == 'off' then
        windower.add_to_chat(200, 'Everything is okay again.' )
        settings.meow = false
        settings:save('all')
    else
        windower.add_to_chat(167, 'Invalid command.')
    end
end)

-- There's probably a way better way to do this and I've probably overlooked something but fuck it this is my angel and you will love her
windower.register_event('incoming chunk', function(id, data)
    if settings.meow == true then
        if id == 0x017 then -- Chat packet
            local chat = packets.parse('incoming', data)
            local mode = chat.Mode
            local author = chat["Sender Name"]
            local incoming_mode = resources.chat[mode].incoming

            local author_string = ""
            local message_string = "meow"

            local mode_author_strings = {
                [0] = "%s : ",      -- Say
                [1] = "%s : ",      -- Shout
                [3] = "%s>> ",      -- Tell
                [4] = "(%s) ",      -- Party
                [5] = "[1]<%s> ",   -- Linkshell 1
                [27] = "[2]<%s> ",  -- Linkshell 2
                [26] = "%s[%s]: ",  -- Yell
                [33] = "{%s} ",     -- Unity
                [34] = "%s(E) : ",  -- AssistE
                [35] = "%s(J) : ",  -- AssistJ
            }

            if mode_author_strings[mode] then -- Ensure that the current mode is relevant
                if mode == 26 then -- Yell
                    local zone_name = resources.zones[chat.Zone].search
                    author_string = string.format(mode_author_strings[mode], author, zone_name)
                else -- Anything else
                    author_string = string.format(mode_author_strings[mode], author)
                end
            end

            -- Aydin check
            if math.random() < 0.1 then
                message_string = "bark"
            end

            windower.add_to_chat(incoming_mode, author_string .. message_string)
            return true
        end

        -- Forget this return false to freeze your game on home points for some reason
        -- I don't know why
        -- But I definitely didn't experience this nooooo
        return false
    end
end)