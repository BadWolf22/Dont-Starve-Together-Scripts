local SignGenerator = require"signgenerator"

local writeables = {}

local kinds = {}

kinds["homesign"] = {
    prompt = STRINGS.SIGNS.MENU.PROMPT,
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),

    cancelbtn = { text = STRINGS.SIGNS.MENU.CANCEL, cb = nil, control = CONTROL_CANCEL },
    middlebtn = { text = STRINGS.SIGNS.MENU.RANDOM, cb = function(inst, doer, widget)
            widget:OverrideText( SignGenerator(inst, doer) )
        end, control = CONTROL_MENU_MISC_2 },
    acceptbtn = { text = STRINGS.SIGNS.MENU.ACCEPT, cb = nil, control = CONTROL_ACCEPT },

    --defaulttext = SignGenerator,
}
kinds["arrowsign_post"] = kinds["homesign"]
kinds["arrowsign_panel"] = kinds["homesign"]

kinds["beefalo"] =
{
    prompt = "Name This Beef",
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),

    defaulttext = function(inst, doer)
        return subfmt(STRINGS.NAMES.BEEFALO_BUDDY_NAME, { buddy = doer.name })
    end,

    cancelbtn = {
        text = STRINGS.BEEFALONAMING.MENU.CANCEL,
        cb = nil,
        control = CONTROL_CANCEL
    },
    middlebtn = {
        text = STRINGS.BEEFALONAMING.MENU.RANDOM,
        cb = function(inst, doer, widget)
            local name_index = math.random(#STRINGS.BEEFALONAMING.BEEFNAMES)
            widget:OverrideText( STRINGS.BEEFALONAMING.BEEFNAMES[name_index] )
        end,
        control = CONTROL_MENU_MISC_2
    },
    acceptbtn = {
        text = STRINGS.BEEFALONAMING.MENU.ACCEPT,
        cb = nil,
        control = CONTROL_ACCEPT
    },
}

writeables.makescreen = function(inst, doer)
    local data = kinds[inst.prefab]

    if doer and doer.HUD then
        return doer.HUD:ShowWriteableWidget(inst, data)
    end
end

return writeables
