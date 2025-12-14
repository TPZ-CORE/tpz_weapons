local TPZ = exports.tpz_core:getCoreAPI()

local PlayerData = {
	Job           = nil,
	JobGrade      = 0,

	IsBusy        = false,
	BusyType      = 'N/A',
	CameraHandler = {handler = nil, coords = nil, zoom = 0, z = 0 },

	Store         = { Category = 'WEAPONS', CurrentIndex = 0, MaxIndex = 0 },
	Item          = { ObjectEntity = nil, ObjectEntityModel = nil, ObjectWeapon = false, Loaded = false },

	HasNUIActive  = false,
	Loaded        = false,

}

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------



-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

function GetPlayerData()
	return PlayerData
end

function CloseStoreProperly()

	while not IsScreenFadedOut() do
		Wait(50)
		DoScreenFadeOut(2000)
	end

	if PlayerData.Item.ObjectEntity ~= nil then

		if not PlayerData.Item.ObjectWeapon then
			RemoveEntityProperly(PlayerData.Item.ObjectEntity, GetHashKey(PlayerData.Item.ObjectEntityModel))
		else
			DeleteEntity(PlayerData.Item.ObjectEntity)
		end

	end

	if PlayerData.BusyType == 'CATALOG' then 
		CloseUI()
	end

	DestroyAllCams(true)
	ExecuteCommand("hud:hideall")

	CloseNUI()

	Wait(2000)
	
	PlayerData.BusyType = 'N/A'
	PlayerData.IsBusy   = false
	PlayerData.Store.Category = 'NONE'

	TaskStandStill(PlayerPedId(), 1)
	DoScreenFadeIn(2000)

end

local function FindWeaponComponents(HashName)

    for index, components in pairs(model_specific_components) do

        if GetHashKey(index) == GetHashKey(HashName) then
            return components, index
        end
    end

    return {}, GetHashKey(HashName)
end


local HasRequiredJob = function(jobs)

	for index, job in pairs (jobs) do 
		
		if PlayerData.Job == job then
			return true
		
		end
	
	end

	return false
	
end

-----------------------------------------------------------
--[[ Basic Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

	if PlayerData.Item.ObjectEntity then

		if not PlayerData.Item.ObjectWeapon then
			RemoveEntityProperly(PlayerData.Item.ObjectEntity, GetHashKey(PlayerData.Item.ObjectEntityModel))
		else
			DeleteEntity(PlayerData.Item.ObjectEntity)
		end

	end

    if PlayerData.IsBusy then
		DestroyAllCams(true)
		ExecuteCommand("hud:hideall")
	
		CloseUI()
		TaskStandStill(PlayerPedId(), 1)
	end

end)

AddEventHandler("tpz_core:isPlayerReady", function(newChar)
	Wait(2000)

	local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

	if data == nil then
		return
	end

	PlayerData.Job            = data.job
	PlayerData.JobGrade       = data.jobGrade

	PlayerData.Loaded         = true
    
end)

-- Gets the player job when devmode set to true.
if Config.DevMode then

    Citizen.CreateThread(function ()

		Wait(2000)

        local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

        if data == nil then
            return
        end

		PlayerData.Job            = data.job
		PlayerData.JobGrade       = data.jobGrade

		PlayerData.Loaded         = true

    end)
	
end

-- Updates the player job and job grade in case if changes.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    PlayerData.Job      = data.job
    PlayerData.JobGrade = data.jobGrade
end)

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_weapons:client:updatePlayerAccount")
AddEventHandler("tpz_weapons:client:updatePlayerAccount", function(data)
	UpdatePlayerAccountInformation(data)
end)

RegisterNetEvent("tpz_weapons:loadItemModelToTable")
AddEventHandler("tpz_weapons:loadItemModelToTable", function(locationIndex, data)

	PlayerData.Item.Loaded = false
	
	local StoreData = Config.Stores[locationIndex]

	if PlayerData.Item.ObjectEntity then

		if not PlayerData.Item.ObjectWeapon then
			RemoveEntityProperly(PlayerData.Item.ObjectEntity, GetHashKey(PlayerData.Item.ObjectEntityModel))
		else
			DeleteEntity(PlayerData.Item.ObjectEntity)
		end

	end


	AddTextEntryByHash(GetHashKey(data.HashName), data.Label)

	UpdateStoreUI( { 
		itemLabel       = GetHashKey(data.HashName),
		itemDescription = data.Description,
		purchasePrice   = data.PriceUIDisplay, 
		isGoldPrice     = false,
		tokenPrice      = 0,
		modifiedPriceVisible = data.modifiedPriceVisible,
		purchaseModifiedPrice = data.purchaseModifiedPrice,
		isWeapon = TPZ.StartsWith(data.HashName, 'WEAPON_'),
	} )

	local objectCoords = StoreData.ItemObjectPosition

	if TPZ.StartsWith(data.HashName, 'WEAPON_') then

		Citizen.InvokeNative(0x72D4CB5DB927009C, GetHashKey(data.HashName), 1, true)

		while not Citizen.InvokeNative(0xFF07CF465F48B830, GetHashKey(data.HashName)) do
			Wait(100)
		end

		local weaponObject = Citizen.InvokeNative(0x9888652B8BA77F73, GetHashKey(data.HashName), 1, objectCoords.x, objectCoords.y, objectCoords.z - data.DecreasePlacementHeightBy, true, 1.0)
		
		PlaceObjectOnGroundProperly(weaponObject, true)

		if data.Rotation.Enabled then
			SetEntityRotation(weaponObject, data.Rotation.Pitch, data.Rotation.Roll, data.Rotation.Yaw, 1, true)
		end

		SetEntityCoords(weaponObject,  objectCoords.x, objectCoords.y, objectCoords.z - data.DecreasePlacementHeightBy)

		SetModelAsNoLongerNeeded(data.HashName)

		PlayerData.Item.ObjectEntity      = weaponObject

		PlayerData.Item.ObjectEntityModel = data.HashName
		PlayerData.Item.ObjectWeapon      = true

	else

		LoadModel( data.HashName)

		local object = CreateObject(GetHashKey(data.HashName), vector3(objectCoords.x, objectCoords.y, objectCoords.z), false, false, false, false, false)

		SetEntityVisible(object, true)

		SetEntityCollision(object, true)
		FreezeEntityPosition(object, true)

		PlaceObjectOnGroundProperly(object, true)

		if data.Rotation.Enabled then
			SetEntityRotation(object,data.Rotation.Pitch, data.Rotation.Roll, data.Rotation.Yaw, 2, true)
		end
			
		SetEntityCoordsNoOffset(object,  objectCoords.x, objectCoords.y, objectCoords.z)
			
		PlayerData.Item.ObjectEntity      = object

		PlayerData.Item.ObjectEntityModel = data.HashName
		PlayerData.Item.ObjectWeapon      = false

	end

	local oldZoom = PlayerData.CameraHandler.zoom

	if oldZoom == data.SetCamFov then

		PlayerData.CameraHandler.zoom = data.SetCamFov
		PlayerData.Item.Loaded = true

		return
	end

	Citizen.CreateThread(function()
	
		while PlayerData.CameraHandler.zoom ~= data.SetCamFov do

			Wait(20)

			if oldZoom > data.SetCamFov then
				PlayerData.CameraHandler.zoom = PlayerData.CameraHandler.zoom - 1.0
			else
				PlayerData.CameraHandler.zoom = PlayerData.CameraHandler.zoom + 1.0
			end

			SetCamFov(PlayerData.CameraHandler.handler, PlayerData.CameraHandler.zoom )
			
			if PlayerData.CameraHandler.zoom == data.SetCamFov then
				
				PlayerData.CameraHandler.zoom = data.SetCamFov
				PlayerData.Item.Loaded = true
				break
			end

		end
	
	end)

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompts()

    while true do

        Citizen.Wait(0)
        
        local sleep  = true
        local player = PlayerPedId()
        local isDead = IsEntityDead(player)

        if not isDead and PlayerData.Loaded and PlayerData.BusyType ~= 'CUSTOMIZE' then

			local hour   = GetClockHours()
			local coords = GetEntityCoords(player)

            for index, storeConfig in pairs(Config.Stores) do

				local playerDist  = vector3(coords.x, coords.y, coords.z)

                local storeDist = vector3(storeConfig.Coords.x, storeConfig.Coords.y, storeConfig.Coords.z)
                local distance    = #(playerDist - storeDist)

                local invalidHour = (hour >= storeConfig.Hours.Duration.pm or hour < storeConfig.Hours.Duration.am)

				local isStoreAvailable = true

				if not PlayerData.IsBusy then

					if ( distance > Config.NPCRenderingDistance ) or (storeConfig.Hours.Enabled and invalidHour) then
                    
						if storeConfig.NPC then
							RemoveEntityProperly(storeConfig.NPC, GetHashKey(storeConfig.NPCData.Model))
							Config.Stores[index].NPC = nil
						end
	
					end
	
					if storeConfig.Hours.Enabled and invalidHour then
						isStoreAvailable = false
					end
				end

                if isStoreAvailable then

					if distance <= Config.NPCRenderingDistance and storeConfig.NPC == nil and storeConfig.NPCData.Enabled then
                        SpawnNPC(index)
                    end

                    if distance <= storeConfig.ActionDistance then
                        sleep = false

						local Prompts, PromptsList = GetPromptData()

                        local label = CreateVarString(10, 'LITERAL_STRING', Locales['GUNSMITH_FOOTER_PROMPT_DISPLAY'])

						if PlayerData.IsBusy then

							local footDisplay =	PlayerData.BusyType == 'CATALOG' and string.format(Locales['CATEGORY'], PlayerData.Store.Category) or Locales['CUSTOMIZE_FOOTER_PROMPT_DISPLAY']
							label = CreateVarString(10, 'LITERAL_STRING', footDisplay)
						end

                        PromptSetActiveGroupThisFrame(Prompts, label)
    
						for i, prompt in pairs (PromptsList) do

							PromptSetEnabled(prompt.prompt, 0)
							PromptSetVisible(prompt.prompt, 0)

							if not PlayerData.IsBusy and (prompt.type == 'OPEN_STORE' or prompt.type == 'CUSTOMIZE') then
								PromptSetEnabled(prompt.prompt, 1)
								PromptSetVisible(prompt.prompt, 1)
							end

							if PlayerData.IsBusy and PlayerData.BusyType == 'CATALOG' and prompt.type ~= 'OPEN_STORE' and prompt.type ~= 'CUSTOMIZE' then 
								PromptSetVisible(prompt.prompt, 1)

								if (PlayerData.Store.Category == 'NONE') and ( prompt.type == 'PREVIOUS_ITEM' or prompt.type == 'NEXT_ITEM' or prompt.type == 'BUY' ) then
									PromptSetEnabled(prompt.prompt, 0)
								else
									
									PromptSetEnabled(prompt.prompt, 1)
								end
							end

							if PlayerData.Store.CurrentIndex <= 1 and prompt.type == 'PREVIOUS_ITEM' then
								PromptSetEnabled(prompt.prompt, 0)
							end

							if PlayerData.Store.CurrentIndex == PlayerData.Store.MaxIndex and prompt.type == 'NEXT_ITEM' then
								PromptSetEnabled(prompt.prompt, 0)
							end

							if PlayerData.IsBusy and not PlayerData.Item.Loaded and prompt.type ~= 'EXIT' then
								PromptSetEnabled(prompt.prompt, 0)
							end

							if PromptHasHoldModeCompleted(prompt.prompt) then

								if prompt.type == 'OPEN_STORE' then
	
									while not IsScreenFadedOut() do
										Wait(50)
										DoScreenFadeOut(2000)
									end
										
									PlayerData.IsBusy = true

									TPZ.modules().functions.TeleportToCoords(storeConfig.Coords.x, storeConfig.Coords.y, storeConfig.Coords.z, storeConfig.Coords.h)

									TaskStandStill(player, -1)

									ExecuteCommand("hud:hideall")

									local cameraCoords   = storeConfig.MainCamera
									local _cameraHandler = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.fov, false, 2)
								
									SetCamActive(_cameraHandler, true)
									RenderScriptCams(true, false, 0, true, true, 0)
								
									PlayerData.CameraHandler.handler = _cameraHandler
									PlayerData.CameraHandler.coords  = cameraCoords
								
									PlayerData.CameraHandler.z       = cameraCoords.z
									PlayerData.CameraHandler.zoom    = cameraCoords.fov

									CreateStoreUI( { 
										itemLabel       = 0,
										itemDescription = nil,
										purchasePrice   = 0, 
										isGoldPrice     = false,
										tokenPrice      = 0,
										modifiedPriceVisible =  false,
										purchaseModifiedPrice = 0,
									} )
									
									TriggerEvent('tpz_weapons:loadItemModelToTable', index, Config.Types[storeConfig.StoreProductsType]['WEAPONS'].Items[1] )

									local FirstResultData = Config.Types[storeConfig.StoreProductsType]['WEAPONS'].Items[1]
									
							
									Wait(2000)
									DoScreenFadeIn(2000)

								    Wait(1000)
									
									PlayerData.Store = {
										Category = 'WEAPONS', 
										CurrentIndex = 1, 
										MaxIndex = TPZ.GetTableLength(Config.Types[storeConfig.StoreProductsType]['WEAPONS'].Items)
									}

									DisplayPlayerAccountInformation()

									PlayerData.BusyType = 'CATALOG'
								end

								if prompt.type == 'CATEGORY' then

									local newCategory

									if PlayerData.Store.Category == 'WEAPONS' then
										newCategory = 'AMMUNITION'

										if TPZ.GetTableLength(Config.Types[storeConfig.StoreProductsType]['AMMUNITION'].Items) <= 0 then
											newCategory = 'MISC'
										end

									elseif PlayerData.Store.Category == 'AMMUNITION' then
										newCategory = 'MISC'

										if TPZ.GetTableLength(Config.Types[storeConfig.StoreProductsType]['MISC'].Items) <= 0 then
											newCategory = 'WEAPONS'
										end

									elseif PlayerData.Store.Category == 'MISC' then
										newCategory = 'WEAPONS'

										if TPZ.GetTableLength(Config.Types[storeConfig.StoreProductsType]['WEAPONS'].Items) <= 0 then
											newCategory = 'AMMUNITION'
										end

									end

									TriggerEvent('tpz_weapons:loadItemModelToTable', index, Config.Types[storeConfig.StoreProductsType][newCategory].Items[1] )

									PlayerData.Store = {
										Category = newCategory, 
										CurrentIndex = 1, 
										MaxIndex = TPZ.GetTableLength(Config.Types[storeConfig.StoreProductsType][newCategory].Items) 
									}


								end

								if prompt.type == 'NEXT_ITEM' then

									PlayerData.Store.CurrentIndex = PlayerData.Store.CurrentIndex + 1

									TriggerEvent('tpz_weapons:loadItemModelToTable', index, Config.Types[storeConfig.StoreProductsType][PlayerData.Store.Category].Items[PlayerData.Store.CurrentIndex])
								end

								if prompt.type == 'PREVIOUS_ITEM' then

									PlayerData.Store.CurrentIndex = PlayerData.Store.CurrentIndex - 1
									
									TriggerEvent('tpz_weapons:loadItemModelToTable', index, Config.Types[storeConfig.StoreProductsType][PlayerData.Store.Category].Items[PlayerData.Store.CurrentIndex])
								end

								if prompt.type == 'BUY' then

									local ItemData = Config.Types[storeConfig.StoreProductsType][PlayerData.Store.Category].Items[PlayerData.Store.CurrentIndex]
									local IsWeapon = TPZ.StartsWith(ItemData.Item, 'WEAPON_')

									if ItemData.RequestInputQuantity and not IsWeapon then

										local inputData = {
											title = ItemData.Label,
											desc  = Locales['INPUT_BUY_SELECTED_QUANTITY'],
											buttonparam1 = Locales['INPUT_ACTION_BUY_BUTTON'],
											buttonparam2 = Locales['INPUT_ACTION_CANCEL_BUTTON']
										}

										TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

											if cb == 'DECLINE' or cb == Locales['INPUT_ACTION_CANCEL_BUTTON'] then
												return
											end

											if tonumber(cb) == nil or tonumber(cb) <= 0 then
												TriggerServerEvent('tp_libs:sendNotification', nil, Locales['INVALID_QUANTITY'], "error")
												return 
											end

											TriggerServerEvent("tpz_weapons:server:buySelectedItem", index, PlayerData.Store.Category, PlayerData.Store.CurrentIndex, ItemData.Item, ItemData.Label, tonumber(cb) )
			
										end)
	
									else
	
										TriggerServerEvent("tpz_weapons:server:buySelectedItem", index, PlayerData.Store.Category, PlayerData.Store.CurrentIndex, ItemData.Item, ItemData.Label, 1 )
							
									end

								end

								if prompt.type == 'EXIT' then
									CloseStoreProperly()
								end

								Wait(100)
							end

						end

                    end


				end

			end

		end

		if sleep then
			Wait(1000)
		end

	end

end)


--[[Citizen.CreateThread(function()
	RegisterCustomizationActionPrompt()

	while true do

		Citizen.Wait(0)
		
		local sleep  = true
		local player = PlayerPedId()
		local isDead = IsEntityDead(player)

		if not isDead and PlayerData.Loaded and PlayerData.BusyType ~= 'CUSTOMIZE' then

			local coords = GetEntityCoords(player)
			
			for index, storeConfig in pairs(Config.Stores) do

				local playerDist  = vector3(coords.x, coords.y, coords.z)

				local storeDist = vector3(storeConfig.CustomizationCoords.x, storeConfig.CustomizationCoords.y, storeConfig.CustomizationCoords.z)
				local distance    = #(playerDist - storeDist)

				if distance <= storeConfig.ActionDistance then

					sleep = false

					local Prompts, PromptsList = GetCustomizationPromptData()
					local label = CreateVarString(10, 'LITERAL_STRING', Locales['CUSTOMIZE_FOOTER_PROMPT_DISPLAY'])
					PromptSetActiveGroupThisFrame(Prompts, label)

					if PromptHasHoldModeCompleted(PromptsList) then

						if HasRequiredJob(storeConfig.Jobs) then
							
							PlayerData.IsBusy = true

							while not IsScreenFadedOut() do
								Wait(50)
								DoScreenFadeOut(2000)
							end
						
							TaskStandStill(player, -1)

							ExecuteCommand("hud:hideall")

							local cameraCoords = storeConfig.CustomizationCamera

							local _cameraHandler = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.fov, false, 2)
						
							SetCamActive(_cameraHandler, true)
							RenderScriptCams(true, false, 0, true, true, 0)
						
							PlayerData.CameraHandler.handler = _cameraHandler
							PlayerData.CameraHandler.coords  = cameraCoords
						
							PlayerData.CameraHandler.z       = cameraCoords.z
							PlayerData.CameraHandler.zoom    = cameraCoords.fov
					
							Wait(2000)
							DoScreenFadeIn(2000)
							PlayerData.BusyType = 'CUSTOMIZE'

							DisplayPlayerAccountInformation()
							OpenWeaponCustomization(index)

						else
							TriggerServerEvent('tp_libs:sendNotification', nil, Locales['NOT_REQUIRED_JOB'], "error")
						end

						Wait(50)
					end

				end

			end

		end

		if sleep then
			Citizen.Wait(1000)
		end

	end

end)

Citizen.CreateThread(function()

	RegisterCustomizationZoomActionPrompt()

	while true do

		Citizen.Wait(0)
		
		local sleep  = true
		local player = PlayerPedId()
		local isDead = IsEntityDead(player)

		if not isDead and PlayerData.Loaded and PlayerData.IsBusy and PlayerData.BusyType == 'CUSTOMIZE' and PlayerData.Item.ObjectEntity then
			sleep = false
			
			local Prompts, PromptsList = GetCustomizationZoomPromptData()
			local label = CreateVarString(10, 'LITERAL_STRING', Locales['CUSTOMIZE_FOOTER_PROMPT_DISPLAY'])
			PromptSetActiveGroupThisFrame(Prompts, label)

			if IsControlPressed(2, 0x8BDE7443) then -- zoom out

                if PlayerData.CameraHandler.zoom < 40.0 then -- Zoom out limit

                    PlayerData.CameraHandler.zoom = PlayerData.CameraHandler.zoom + 0.4

					SetCamFov(PlayerData.CameraHandler.handler, PlayerData.CameraHandler.zoom)
                end
            end

            if IsControlPressed(2, 0x62800C92) then -- zoom in

                if PlayerData.CameraHandler.zoom > 8.0 then -- Zoom in limit

                    PlayerData.CameraHandler.zoom = PlayerData.CameraHandler.zoom - 0.4

					SetCamFov(PlayerData.CameraHandler.handler, PlayerData.CameraHandler.zoom)
                end

            end

		end

		if sleep then
			Citizen.Wait(1000)
		end

	end

end)]]--






