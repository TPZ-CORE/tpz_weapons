
-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

ToggleUI = function(display)

	SetNuiFocus(false,false)

    if not display then
        DisplayingNUI = false
    end

    SendNUIMessage({ type = "enable", enable = display })
end

-----------------------------------------------------------
--[[ Public Functions ]]--
-----------------------------------------------------------

function DisplayPlayerAccountInformation()

    local PlayerData = GetPlayerData()

    if PlayerData.HasNUIActive then
        return
    end

    TriggerServerEvent("tpz_weapons:requestPlayerAccount")
    
    GetPlayerData().HasNUIActive = true

    Wait(250)
    ToggleUI(true)

end

function UpdatePlayerAccountInformation(data)

    SendNUIMessage({ 
        action   = 'updatePlayerAccountInformation',
        accounts = { dollars = data[1] }
    })

end

function CloseNUI()
    GetPlayerData().HasNUIActive = false

    SendNUIMessage({action = 'close'})
end

-----------------------------------------------------------
--[[ NUI Callbacks  ]]--
-----------------------------------------------------------

RegisterNUICallback('close', function()

    Wait(1000)
	ToggleUI(false)
end)
