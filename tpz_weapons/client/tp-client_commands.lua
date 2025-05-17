
-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

function showstats()
	local _, weapon = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
	if weapon then	

      --  ExecuteCommand("hidehud")
        -- DISABLE HUD
        local uiFlowBlock = RequestFlowBlock(GetHashKey("PM_FLOW_WEAPON_INSPECT"))
        local uiContainer = DatabindingAddDataContainerFromPath("" , "ItemInspection")
        Citizen.InvokeNative(0x46DB71883EE9D5AF, uiContainer, "stats", getWeaponStats(weapon), PlayerPedId())
        DatabindingAddDataString(uiContainer, "tipText", "Weapon Information")
        DatabindingAddDataHash(uiContainer, "itemLabel", weapon)
        DatabindingAddDataBool(uiContainer, "Visible", true)

        Citizen.InvokeNative(0x10A93C057B6BD944, uiFlowBlock)
        Citizen.InvokeNative(0x3B7519720C9DCB45, uiFlowBlock, 0)
        Citizen.InvokeNative(0x4C6F2C4B7A03A266, -813354801, uiFlowBlock)
    end
end

function getWeaponStats(weaponHash) 
    local emptyStruct = DataView.ArrayBuffer(256)
    local charStruct = DataView.ArrayBuffer(256)
    Citizen.InvokeNative(0x886DFD3E185C8A89, 1, emptyStruct:Buffer(), GetHashKey("CHARACTER"), -1591664384, charStruct:Buffer())
        
    local unkStruct = DataView.ArrayBuffer(256)
    Citizen.InvokeNative(0x886DFD3E185C8A89, 1, charStruct:Buffer(), 923904168, -740156546, unkStruct:Buffer())

    local weaponStruct = DataView.ArrayBuffer(256)
    Citizen.InvokeNative(0x886DFD3E185C8A89, 1, unkStruct:Buffer(), weaponHash, -1591664384, weaponStruct:Buffer())
    return weaponStruct:Buffer()
end

function GetLabelText(WeaponObject)
    local WeaponDegradation          = Citizen.InvokeNative(0x0D78E1097F89E637 ,WeaponObject , Citizen.ResultAsFloat())
    local WeaponPernamentDegradation = Citizen.InvokeNative(0xD56E5F336C675EFA ,WeaponObject , Citizen.ResultAsFloat())

    if WeaponDegradation == 0.0 then
        return GetLabelTextByHash(1803343570)
    end

    if WeaponPernamentDegradation > 0.0 and WeaponDegradation == WeaponPernamentDegradation then
        return GetLabelTextByHash(-1933427003)
    end
	
    return GetLabelTextByHash(-54957657)
end

function checkgun()


    local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
    local interaction = "LONGARM_HOLD_ENTER"
    local act = GetHashKey("LONGARM_CLEAN_ENTER")
    local object = GetObjectIndexFromEntityIndex(GetCurrentPedWeaponEntityIndex(PlayerPedId(),0))
    local cleaning = false 
    Citizen.InvokeNative(0xCB9401F918CB0F75, PlayerPedId(), "GENERIC_WEAPON_CLEAN_PROMPT_AVAILABLE", true, -1)
    if Citizen.InvokeNative(0xD955FEE4B87AFA07,weaponHash) then
        interaction = "SHORTARM_HOLD_ENTER"
        act = GetHashKey("SHORTARM_CLEAN_ENTER")
    end
    if weaponHash ~= -1569615261 then
        TaskItemInteraction(PlayerPedId(), weaponHash, GetHashKey(interaction), 0,0,0) 
        showstats()
        while not Citizen.InvokeNative(0xEC7E480FF8BD0BED,PlayerPedId()) do
            Wait(300)
        end		  
        while Citizen.InvokeNative(0xEC7E480FF8BD0BED,PlayerPedId()) do
            Wait(1) 
            if IsDisabledControlJustReleased(0,3002300392) then
                ClearPedTasks(PlayerPedId(),1,1)
                Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)	
              --  ExecuteCommand("hidehud")
            end

            if IsDisabledControlJustReleased(0,3820983707) and not cleaning then

                --TriggerEvent("vorp:ExecuteServerCallBack", "tp_syn_weapons:hasRequiredItem", function(hasRequiredItem)

                    if not hasRequiredItem then
                        ClearPedTasks(PlayerPedId(),1,1)
                        Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)	
                   --     ExecuteCommand("hidehud")

                        --TriggerEvent("vorp:TipBottom", "~e~You don't have a weapons cloth to clean the weapon.", 4000)

                    end

                --end, {item = "cleanshort"})
				
                break
            end
        end
        Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)	
    end

end

-----------------------------------------------------------
--[[ Commands  ]]--
-----------------------------------------------------------

RegisterCommand('inspect', function(source, args, raw)
    Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)	
    
    local ped           = PlayerPedId()
    local currentWeapon = GetCurrentPedWeaponEntityIndex(ped, 0)

    local _, weaponHash = GetCurrentPedWeapon(ped, true, 0, true)
    local WeaponType    = GetWeaponType(weaponHash)

    if weaponHash == `WEAPON_UNARMED` then
		return 
	end

    if WeaponType == "SHOTGUN" then 
		WeaponType = "LONGARM" 
	end

    if WeaponType == "MELEE" then 
		WeaponType = "SHORTARM" 
	end

	if WeaponType == "BOW" then 
		WeaponType = "SHORTARM" 
	end

end)