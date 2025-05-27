local Prompts, CustomizationPrompts, CustomizationZoomPrompts = GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff)
local PromptsList, CustomizationPromptsList, CustomizationZoomPromptsList = {}, {}, {}

local TextureDicts = {"rpg_meter", "rpg_meter_track", "generic_textures"}

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

local PromptTypesList = {

    [1] = {
        Type = "OPEN_STORE"
    },

    [2] = {

        Type = "PREVIOUS_ITEM"
    },

    [3] = {

        Type = "NEXT_ITEM"
    },

    [4] = {

        Type = "BUY"
    },


    [5] = {

        Type = "CATEGORY"
    },

    [6] = {

        Type = "EXIT"
    },

}

RegisterActionPrompts = function()

    for index, tprompt in pairs (PromptTypesList) do

 
        local str      = Config.PromptKeys[tprompt.Type].label
        local keyPress = Config.PromptKeys[tprompt.Type].key
    
        local dPrompt = PromptRegisterBegin()
        PromptSetControlAction(dPrompt, keyPress)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(dPrompt, str)
        PromptSetEnabled(dPrompt, 1)
        PromptSetVisible(dPrompt, 1)
        PromptSetStandardMode(dPrompt, 1)
        PromptSetHoldMode(dPrompt, Config.PromptKeys[tprompt.Type].hold)
        PromptSetGroup(dPrompt, Prompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
        PromptRegisterEnd(dPrompt)
    
        table.insert(PromptsList, {prompt = dPrompt, type = tprompt.Type})

    end

end

GetPromptData = function ()
    return Prompts, PromptsList
end

--[[RegisterCustomizationActionPrompt = function()

    local str      = Config.CustomizationPromptKey.label
    local keyPress = Config.CustomizationPromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, Config.CustomizationPromptKey.hold)
    PromptSetGroup(dPrompt, CustomizationPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    CustomizationPromptsList = dPrompt

end

GetCustomizationPromptData = function ()
    return CustomizationPrompts, CustomizationPromptsList
end]]--

RegisterCustomizationZoomActionPrompt = function()

    local str       = Config.CustomizationZoomPromptKeys.label
    local keyPress1 = Config.CustomizationZoomPromptKeys.key1
    local keyPress2 = Config.CustomizationZoomPromptKeys.key2

    local dPrompt = PromptRegisterBegin()

    PromptSetControlAction(dPrompt, keyPress1)
    PromptSetControlAction(dPrompt, keyPress2)

    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 0)
    PromptSetHoldMode(dPrompt, false)
    PromptSetGroup(dPrompt, CustomizationZoomPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    CustomizationZoomPromptsList = dPrompt

end

GetCustomizationZoomPromptData = function ()
    return CustomizationZoomPrompts, CustomizationZoomPromptsList
end

--[[-------------------------------------------------------
 Events
]]---------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompts) -- UiPromptDelete
    Citizen.InvokeNative(0x00EDE88D4D13CF59, CustomizationPrompts)

    for i, store in pairs (Config.Stores) do

        if store.BlipHandle then
            RemoveBlip(store.BlipHandle)
        end

        if store.NPC then
            RemoveEntityProperly(store.NPC, joaat(store.NPCData.Model))
        end

    end

    Prompts, CustomizationPrompts = nil, nil
    PromptsList, CustomizationPromptsList = nil, nil
end)



--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

Citizen.CreateThread(function ()

    for index, store in pairs (Config.Stores) do

        if store.BlipData and store.BlipData.Enabled then

            local blipHandle = N_0x554d9d53f696d002(1664425300, store.BlipData.Coords.x, store.BlipData.Coords.y, store.BlipData.Coords.z)
    
            SetBlipSprite(blipHandle, store.BlipData.Sprite, 1)
            SetBlipScale(blipHandle, 0.1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, store.BlipData.Title)

            Config.Stores[index].BlipHandle = blipHandle
        end

    end
end)


--[[-------------------------------------------------------
 General Functions
]]---------------------------------------------------------

function LoadModel(inputModel)
    local model = joaat(inputModel)
 
    RequestModel(model)
 
    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(10)
    end
end

function RemoveEntityProperly(entity, objectHash)
	DeleteEntity(entity)
	DeletePed(entity)
	SetEntityAsNoLongerNeeded( entity )

	if objectHash then
		SetModelAsNoLongerNeeded(objectHash)
	end
end

function SpawnNPC(index)
    local v = Config.Stores[index].NPCData

    LoadModel(v.Model)

    if v.Enabled then
        local npc = CreatePed(v.Model, v.Coords.x, v.Coords.y, v.Coords.z, v.Coords.h, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        if v.Scenario.Enabled then
            TaskStartScenarioInPlace(npc, joaat(v.Scenario.HashName), -1)
        end

        Config.Stores[index].NPC = npc


    end
end

function RequestAnim(dict)

    if not DoesAnimDictExist(dict) then
		return false
	end

	RequestAnimDict(dict)

	while not HasAnimDictLoaded(dict) do
		Wait(10)
	end

end

function RequestDict(dicts)
    for k, v in pairs(dicts) do
        while not HasStreamedTextureDictLoaded(v) do
            Wait(0)
            RequestStreamedTextureDict(v, true)
        end
    end
end

DisplayProgressBar = function(time, desciption, cb)
    RequestDict(TextureDicts)
    local timer = (time / 100)
    local DisplayElemet = 0
    Citizen.CreateThread(function()
        while DisplayElemet < 99 do
            Wait(1)
            DrawSprite("generic_textures", "counter_bg_1b", 0.5, 0.9, 0.023, 0.04, 0.0, 0, 0, 0, 255)
            DrawSprite("rpg_meter_track", "rpg_meter_track_9", 0.5, 0.9, 0.03, 0.05, 0.0, 176, 176, 176, 120)
            DrawSprite("rpg_meter", "rpg_meter_" .. DisplayElemet, 0.5, 0.9, 0.03, 0.05, 0.0, 225, 225, 225, 255)
            Text(0.5001, 0.89, 0.28, tostring(DisplayElemet + 1), {225, 225, 225}, false, true)
            Text(0.5001, 0.93, 0.28, desciption, {255, 255, 255}, false, true)
        end
    end)
    
    if cb then
        Citizen.CreateThread(function()
            cb()
        end)
    end

    while DisplayElemet < 100 do
        DisplayElemet = DisplayElemet + 1
        Wait(timer)
    end
end

function Text(x, y, scale, text, colour, align, force, w)
    local colour = colour or Config.GUI.TextColor
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextFontForCurrentCommand(7)
    SetTextScale(scale, scale)
    Citizen.InvokeNative(1758329440 & 0xFFFFFFFF, align)
    SetTextColor(colour[1], colour[2], colour[3], 255)
    if w then
        Citizen.InvokeNative(1868606292 & 0xFFFFFFFF, w.x, w.y)
    end
    SetTextDropshadow(3, 0, 0, 0, 255)
    DisplayText(str, x, y)
end

-- @GetTableLength returns the length of a table.
function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end