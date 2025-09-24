_addon.name = 'Meow'
_addon.author = 'Rose'
_addon.version = '1.1'
_addon.language = 'english'
_addon.commands = {'meow'}

-- Command usage:
-- "//meow toggle (global on/off)".
-- "//meow toggle <chat mode>".

-- Require
config = require('config')
packets = require('packets')
resources = require('resources')

-- For Aydin check
math.randomseed(os.time())

-- Chat Modes
chat_modes = {
    [0] = {name = "say", author_format = "%s : "},
    [1] = {name = "shout", author_format = "%s : "},
    [3] = {name = "tell", author_format = "%s>> "},
    [4] = {name = "party", author_format = "(%s) "},
    [5] = {name = "linkshell", author_format = "[1]<%s> "},
    [27] = {name = "linkshell2", author_format = "[2]<%s> "},
    [26] = {name = "yell", author_format = "%s[%s]: "},
    [33] = {name = "unity", author_format = "{%s} "},
    [34] = {name = "assiste", author_format = "%s(E) : "},
    [35] = {name = "assistj", author_format = "%s(J) : "},
}

-- Config
defaults = {}
defaults.meow = false
defaults.toggles = {}

for id, _ in pairs(chat_modes) do
    defaults.toggles[id] = {enabled = true}
end

settings = config.load(defaults)

windower.register_event('addon command', function(...)
    -- Check that we have a command
    if #arg < 1 then
        windower.add_to_chat(167, 'Missing command.')
        return
    end

    if arg[1]:lower() == 'toggle' then
        
        if #arg < 2 then
            -- Missing subcommand, so just toggle overall
            settings.meow = not settings.meow
            local message = settings.meow and "enabled" or "disabled"
            windower.add_to_chat(200, string.format('Meowing %s.', message))
        else
            -- We have a subcommand, so find the chat mode id of the name given
            local id_match = nil

            for id, mode in pairs(chat_modes) do
                if mode.name == arg[2]:lower() then
                    id_match = id
                    break
                end
            end

            -- Toggle the setting for said chat mode
            if id_match then
                settings.toggles[id_match].enabled = not settings.toggles[id_match].enabled
                local message = settings.toggles[id_match].enabled and "enabled" or "disabled"

                windower.add_to_chat(200, string.format("Meowing for %s %s.", arg[2]:lower(), message))
                
            else
                windower.add_to_chat(167, 'Invalid chat mode.')
            end
        end

        settings:save('all')
    elseif arg[1]:lower() == 'help' then
        windower.add_to_chat(167, 'meow toggle (global on/off)')
        windower.add_to_chat(167, 'meow toggle <chat mode>')
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

            if chat_modes[mode] and settings.toggles[mode].enabled then -- Ensure that the current mode is relevant and enabled
                if mode == 26 then -- Yell
                    local zone_name = resources.zones[chat.Zone].search
                    author_string = string.format(chat_modes[mode].author_format, author, zone_name)
                else -- Anything else
                    author_string = string.format(chat_modes[mode].author_format, author)
                end

                -- Aydin check
                if math.random() < 0.1 then
                    message_string = "bark"
                end

                windower.add_to_chat(incoming_mode, author_string .. message_string)
                return true
            end
        end
    end
end)