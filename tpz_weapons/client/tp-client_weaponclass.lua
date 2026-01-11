local TPZ = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI()

local StoredWeaponsList = {
  ['WEAPON_FISHINGROD']                  = true,

  ['WEAPON_KIT_CAMERA']                  = true,
  ['WEAPON_KIT_CAMERA_ADVANCED']         = true,

  ['WEAPON_KIT_BINOCULARS']              = true,
  ['WEAPON_KIT_BINOCULARS_IMPROVED']     = true,

  ['WEAPON_MOONSHINEJUG_MP']             = true,

  ['WEAPON_MELEE_TORCH']                 = true,
  ['WEAPON_MELEE_LANTERN']               = true,
  ['WEAPON_MELEE_DAVY_LANTERN']          = true,
  ['WEAPON_MELEE_LANTERN_HALLOWEEN']     = true,
  ['WEAPON_MELEE_LANTERN_ELECTRIC']      = true,

  ['WEAPON_KIT_METAL_DETECTOR']          = true,
}

local UsedWeapon = { guid = nil, weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

function GetWeaponType(hash)

  if Citizen.InvokeNative(0x959383DCD42040DA, hash)  or Citizen.InvokeNative(0x792E3EF76C911959 , hash)   then
    return "MELEE_BLADE"
  
  elseif Citizen.InvokeNative(0x6AD66548840472E5, hash) or Citizen.InvokeNative(0x0A82317B7EBFC420, hash) or Citizen.InvokeNative(0xDDB2578E95EF7138, hash) then
    return "LONGARM"

  elseif  Citizen.InvokeNative(0xC75386174ECE95D5, hash) then
    return "SHOTGUN"
 
  elseif  Citizen.InvokeNative(0xDDC64F5E31EEDAB6, hash) or Citizen.InvokeNative(0xC212F1D05A8232BB , hash) then
    return "SHORTARM"
  end

  return false
end

function IsFirableWeapon(hash)
  return Citizen.InvokeNative(0x6AD66548840472E5, hash) or Citizen.InvokeNative(0x705BE297EEBDB95D, hash) or Citizen.InvokeNative(0xC4DEC3CA8C365A5D, hash) or Citizen.InvokeNative(0xDDC64F5E31EEDAB6, hash) or Citizen.InvokeNative(0xDDB2578E95EF7138, hash) or Citizen.InvokeNative(0xC212F1D05A8232BB, hash) or Citizen.InvokeNative(0x0A82317B7EBFC420, hash) or Citizen.InvokeNative(0xC75386174ECE95D5, hash)
end

-----------------------------------------------------------
--[[ Public Functions  ]]--
-----------------------------------------------------------

-- @ClearUsedWeaponData : Is used for exports.
function SaveUsedWeaponData()

  if UsedWeapon.weaponId then
  
    TriggerServerEvent("tpz_inventory:setDefaultUsedWeapon", "0")

    --if UsedWeapon.ammoType then
    --	local ammo = GetAmmoInPedWeapon(PlayerPedId(), joaat(UsedWeapon.hash))
    --	TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_AMMO", ammo - 1)
    --end
  
    local weaponDirtLevel = Citizen.InvokeNative(0x810E8AE9AFEA7E54, UsedWeapon.weaponObject)
    if weaponDirtLevel then
      TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, 'DIRT_LEVEL', weaponDirtLevel)
    end
  
  end

end

-- @ClearUsedWeaponData : Is used for exports.
function ClearUsedWeaponData(refresh)
  UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }

  if refresh then
    Wait(150)
    RefreshCurrentWeapons()
  end

end

function GetUsedWeaponData()
  return UsedWeapon
end

function IsReloadingWeapon()
  return UsedWeapon.reloadingWeapon
end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  UserWeapon = nil

  SetCurrentPedWeapon(PlayerPedId(), joaat("WEAPON_UNARMED"), true, 0, false, false)

  Citizen.InvokeNative(0x1B83C0DEEBCBB214, PlayerPedId())
  RemoveAllPedWeapons(PlayerPedId(), true, true)

end)

-- @tpz_core:isPlayerRespawned : When player is respawning after death - not char select, we clear the weapon from hands and all data.
RegisterNetEvent("tpz_core:isPlayerRespawned")
AddEventHandler("tpz_core:isPlayerRespawned", function()

  SaveUsedWeaponData()
  ClearUsedWeaponData(false)

  SetCurrentPedWeapon(PlayerPedId(), joaat("WEAPON_UNARMED"), true, 0, false, false)

  Citizen.InvokeNative(0x1B83C0DEEBCBB214, PlayerPedId())
  RemoveAllPedWeapons(PlayerPedId(), true, true)
end)


-- @tpz_core:isPlayerReady : After selecting a character, we request the player inventory contents.
AddEventHandler("tpz_core:isPlayerReady", function(newChar)
  Wait(2000)

  -- If devmode is enabled, we are not running the following code since it already does.
  if Config.DevMode then
    return
  end

  ReloadWeaponsOnCharacterSelect()

end)

if Config.DevMode then

  Citizen.CreateThread(function()
    Wait(2000)

    ReloadWeaponsOnCharacterSelect()

  end)

end

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_weapons:client:clearReloadingState")
AddEventHandler("tpz_weapons:client:clearReloadingState", function()
  UsedWeapon.reloadingWeapon = false
end)

RegisterNetEvent("tpz_weapons:client:reloadWeaponAmmoByWeaponId")
AddEventHandler("tpz_weapons:client:reloadWeaponAmmoByWeaponId", function(weaponId, ammo)

  if weaponId ~= UsedWeapon.weaponId then

    UsedWeapon.reloadingWeapon = false
    return
  end
  
  if ammo ~= 0 then

    local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), joaat(UsedWeapon.hash))
  
    Citizen.InvokeNative(0x106A811C6D3035F3, PlayerPedId(), joaat(UsedWeapon.ammoType), ammo, 0xCA3454E6)
    UsedWeapon.ammo = currentAmmo + ammo
  
    TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_AMMO", UsedWeapon.ammo)
  
  end

  UsedWeapon.reloadingWeapon = false
end)

-----------------------------------------------------------
--[[ Weapon Functions  ]]--
-----------------------------------------------------------

function ReloadWeaponsOnCharacterSelect()

  local PlayerData = TPZInv.getPlayerData()

  while not PlayerData.HasLoadedContents do
    Wait(500)
  end

  local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

  -- If player is in session we return the rest of the code.
  if data == nil then
    return
  end

  -- We avoid any kind of looping since there is no default weapon set.
  if data.defaultWeapon == nil or data.defaultWeapon == '0' then
    return
  end

  local exists = false

  for index, content in pairs (PlayerData.Inventory) do

    if content.type == "weapon" and content.itemId == data.defaultWeapon then

      exists = true

      EquipWeapon(
        content.itemId, 
        content.item, 
        content.metadata.ammoType,
        content.metadata.ammo, 
        content.label, 
        content.metadata.durability, 
        content.metadata
      )


    end

  end

  -- If the default weapon does not exist, we set it as 0.
  if not exists then
    TriggerServerEvent("tpz_inventory:setDefaultUsedWeapon", "0")
  end


end

EquipWeapon = function(itemId, hash, ammoType, ammo, label, durability, metadata)

  if durability ~= -1 and durability == 0 then
    SendNotification(nil, Locales['NO_WEAPON_DURABILITY'], 'error' )
    return
  end
  
  local localAmmoType = Citizen.InvokeNative(0x5C2EA6C44F515F34, joaat(string.upper(hash)))
  
  if UsedWeapon.weaponId == itemId then
    SendNotification(nil, Locales['ALREADY_USING'], 'error' )
    return
  end
  
  local isWeaponThrowable  = Citizen.InvokeNative(0x30E7C16B12DA8211, joaat( string.upper(hash) ) )
  
  if isWeaponThrowable then
    ammo = 1
  end

  local weaponGroup = GetWeapontypeGroup(joaat( string.upper(hash) ))

  if UsedWeapon.hash == "WEAPON_RIFLE_VARMINT" then 
    weaponGroup = tostring(weaponGroup) .. '1'
  end
  
  if ammoType == nil then
  
    local SharedWeapons = TPZInv.getSharedWeapons()

    local getAmmoType   = SharedWeapons.AmmoTypes[tostring(weaponGroup)]
  
    if getAmmoType then
      ammoType = getAmmoType[1]
  
      TriggerServerEvent("tpz_inventory:setWeaponMetadata", itemId, "AMMO_TYPE", ammoType)
    end
  end
  
  UsedWeapon.weaponId   = itemId
  UsedWeapon.hash       = string.upper(hash)
  UsedWeapon.ammoType   = ammoType
  UsedWeapon.ammo       = ammo
  UsedWeapon.name       = label
  UsedWeapon.durability = durability
  UsedWeapon.metadata   = metadata

  RefreshCurrentWeapons()

  TriggerEvent("tpz_weapons:client:run_weapon_tasks")
end

function RefreshCurrentWeapons()

  local playerPedId = PlayerPedId()

  Citizen.InvokeNative(0x1B83C0DEEBCBB214, playerPedId)
  RemoveAllPedWeapons(playerPedId, true, true)

  if UsedWeapon.weaponId and UsedWeapon.hash ~= nil then
    
    -- AddWardrobeInventoryItem("CLOTHING_ITEM_M_OFFHAND_000_TINT_004", 0xF20B6B4A);
    -- AddWardrobeInventoryItem("UPGRADE_OFFHAND_HOLSTER", 0x39E57B01);

    local WeaponHash  = joaat(UsedWeapon.hash)
    local addReason   = ADD_REASON_DEFAULT
    local slotHash    = joaat('SLOTID_WEAPON_0')
    local inventoryId = 1
    local slot        = 0

    local model = GetWeapontypeModel(WeaponHash)

    RequestModel(model)

    while not HasModelLoaded(model) do
      Wait(0)
    end

    local isValid = ItemdatabaseIsKeyValid(WeaponHash, 0)

    if not isValid then
      print("Weapon not valid")
      return false
    end

    local characterItem = getGuidFromItemId(inventoryId, nil, joaat("CHARACTER"), 0xA1212100) --return func_1367(joaat("CHARACTER"), func_2485(), -1591664384, bParam0);
    if not characterItem then
      print("featureless")
      return false
    end

    local weaponItem = getGuidFromItemId(inventoryId, characterItem:Buffer(), 923904168, -740156546) --return func_1367(923904168, func_1889(1), -740156546, 0);
    if not weaponItem then
      print("sem armas")
      return false
    end

    local itemData = DataView.ArrayBuffer(8 * 13)
    local isAdded = InventoryAddItemWithGuid(inventoryId, itemData:Buffer(), weaponItem:Buffer(), WeaponHash, slotHash, 1, addReason)
    if not isAdded then
      print("Not added")
      return false
    end

    local equipped = InventoryEquipItemWithGuid(inventoryId, itemData:Buffer(), true)
    if not equipped then
        print("Unable to equip")
        return false
    end

    Citizen.InvokeNative(0x12FB95FE3D579238, playerPedId, itemData:Buffer(), true, slot, false, false)

    UsedWeapon.guid = itemData:Buffer()

    -- Sets as default
    TriggerServerEvent("tpz_inventory:setDefaultUsedWeapon", UsedWeapon.weaponId)

    local weaponObject = GetCurrentPedWeaponEntityIndex(playerPedId, 0)

    if UsedWeapon.ammo == 0 then
      UsedWeapon.ammo = 1
    end

    if UsedWeapon.ammoType then
      Citizen.InvokeNative(0x106A811C6D3035F3, playerPedId, joaat(UsedWeapon.ammoType), UsedWeapon.ammo, 0xCA3454E6)
    else
      SetPedAmmo(playerPedId, joaat(UsedWeapon.hash), UsedWeapon.ammo)
    end

    if UsedWeapon.metadata.dirtLevel then
      Citizen.InvokeNative(0x812CE61DEBCAB948, weaponObject, UsedWeapon.metadata.dirtLevel, true)
    end

    if UsedWeapon.metadata.components and TPZ.GetTableLength(UsedWeapon.metadata.components) > 0 then

      RemoveAllWeaponComponents()

      -- First we load the weapon components (not shared ones but based on the weapon hash)
      for name, component in pairs (UsedWeapon.metadata.components) do

        if model_specific_components[UsedWeapon.hash] and model_specific_components[UsedWeapon.hash][name] then
  
          local model = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(component) )
  
          if model then
            LoadModel(model)
          end
          
          Citizen.InvokeNative(0x74C9090FDD1BB48E, playerPedId, joaat(component), WeaponHash, true)

          if Config.Debug then
            print('Added a component (Model Specific Component): ' .. name .. ', ' .. component)
          end

        end
  
      end

      local weaponType = GetWeaponType(WeaponHash)

      for name, component in pairs (UsedWeapon.metadata.components) do
  
        if shared_components[weaponType] and shared_components[weaponType][name] then
  
          local model = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(component) )
  
          if model then
            LoadModel(model)
          end

          --if name ~= 'BARREL_MATERIAL' then
            apply_weapon_component(component)
  
          --  if Config.Debug then
          --    print('Added a component (Shared Component): ' .. name .. ', ' .. component)
          --  end

          --else
            --local WeaponObject = GetCurrentPedWeaponEntityIndex(playerPedId, 0)
            --ApplyWeaponComponent(WeaponObject, joaat(component), slotHash)

          --end
          --Citizen.InvokeNative(0x74C9090FDD1BB48E, playerPedId, joaat(component), WeaponHash, true)

         -- ApplyWeaponComponent(weaponObject, joaat(component), 1)
        end
  
      end

    end

  end

end

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

AddEventHandler("tpz_weapons:client:run_weapon_tasks", function()

end)


-- (!) All tasks are running properly based on the holding weapon, some tasks are based only for lanterns and torches,
-- some other tasks only for knifes, others only for throwables and firing weapons, the tasks will run based on the weapon
-- you are holding for better performance.

-- Knives EntityDamageEvent because there is no Function from Natives that triggers it.
Citizen.CreateThread(function()

  while true do

    local sleep         = 1250
    local isWeaponKnife = Citizen.InvokeNative(0x792E3EF76C911959, weaponHash)

    if not UsedWeapon.weaponId and not UsedWeapon.ammoType == nil and not isWeaponKnife then 
      goto END
    end

    if isWeaponKnife then 

      local size = GetNumberOfEvents(0)
  
      removeDurability = false

      if size > 0 then

        sleep = 0
  
        for index = 0, size - 1 do
          local event = GetEventAtIndex(0, index)
  
          if event == joaat("EVENT_ENTITY_DAMAGED") then
  
            local eventDataSize = 9  -- for EVENT_ENTITY_DAMAGED data size is 9
            local eventDataStruct = DataView.ArrayBuffer(8 * eventDataSize) -- buffer must be 8*eventDataSize or bigger
  
            eventDataStruct:SetInt32(8 * 1, 0)		 	-- 8*0 offset for 0 element of eventData
            eventDataStruct:SetInt32(8 * 2, 0)		 	-- 8*0 offset for 0 element of eventData
  
            local is_data_exists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA,0, index,eventDataStruct:Buffer(),eventDataSize)	-- GET_EVENT_DATA
  
            if is_data_exists then
  
              local attacker   = eventDataStruct:GetInt32(8 * 1)
              local weaponHash = eventDataStruct:GetInt32(8 * 2)

              -- Ensure the player who enacted on the event is the one who must get the rewards
              if PlayerPedId() == attacker then 
  
                local SharedWeapons = TPZInv.getSharedWeapons()
  
                if SharedWeapons.Weapons[UsedWeapon.hash].removeDurabilityValue ~= false then
              
                  local WeaponData   = SharedWeapons.Weapons[UsedWeapon.hash]
    
                  local randomChance = math.random(1, 100)
                  local removeValue  = WeaponData.removeDurabilityValue[1]
        
                  if WeaponData.removeDurabilityValue[2] then 
                    local randomValue = math.random(WeaponData.removeDurabilityValue[1], WeaponData.removeDurabilityValue[2])
                    removeValue = randomValue
                  end
        
                  if removeValue ~= 0 and randomChance <= WeaponData.removeDurabilityChance then
                    UsedWeapon.durability = UsedWeapon.durability - removeValue
          
                    if UsedWeapon.durability <= 0 then
                      UsedWeapon.durability = 0
        
                      TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", 0)
      
                      SaveUsedWeaponData()
      
                      UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }
                      RefreshCurrentWeapons()
      
                    else
                      TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", UsedWeapon.durability)
                    end
        
                  end
    
                  
                end
                
              end
  
            end
  
          end

        end

      end
    
    end

    ::END::
    Wait(sleep)

  end
    
end)


Citizen.CreateThread(function()

  while true do

    local sleep = 1000
    local size  = GetNumberOfEvents(0)

    if size <= 0 then 
      goto END
    end

    if size > 0 then

      sleep = 0

      for index = 0, size - 1 do

        local event = GetEventAtIndex(0, index)

        if event == `EVENT_LOOT_COMPLETE` then

          local eventDataSize = 3  -- for EVENT_LOOT_COMPLETE data size is 9
          local eventDataStruct = DataView.ArrayBuffer(8 * eventDataSize) -- buffer must be 8*eventDataSize or bigger

          eventDataStruct:SetInt32(8 * 0, 0) 	-- 8*0 offset for 0 element of eventData
          eventDataStruct:SetInt32(8 * 1, 0)	  -- 8*0 offset for 0 element of eventData
          eventDataStruct:SetInt32(8 * 2, 0)  -- 8*0 offset for 0 element of eventData

          local is_data_exists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA,0, index,eventDataStruct:Buffer(),eventDataSize)	-- GET_EVENT_DATA

          if is_data_exists then

            local looterId       = eventDataStruct:GetInt32(8 * 0) 	-- 8*0 offset for 0 element of eventData
            local lootedEntityId = eventDataStruct:GetInt32(8 * 1)	  -- 8*0 offset for 0 element of eventData
            local isLootSuccess  = eventDataStruct:GetInt32(8 * 2)  -- 8*0 offset for 0 element of eventData

            if PlayerPedId() == looterId and isLootSuccess == 1 then
              
              local model = GetEntityModel(lootedEntityId)

              if model then 

                local SharedWeapons = TPZInv.getSharedWeapons()
  
                if SharedWeapons.Weapons[UsedWeapon.hash] then
                  
                  if SharedWeapons.Weapons[UsedWeapon.hash].removeDurabilityValue ~= false then
              
                    local WeaponData   = SharedWeapons.Weapons[UsedWeapon.hash]
      
                    local randomChance = math.random(1, 100)
                    local removeValue  = WeaponData.removeDurabilityValue[1]
          
                    if WeaponData.removeDurabilityValue[2] then 
                      local randomValue = math.random(WeaponData.removeDurabilityValue[1], WeaponData.removeDurabilityValue[2])
                      removeValue = randomValue
                    end
          
                    if removeValue ~= 0 and randomChance <= WeaponData.removeDurabilityChance then
                      UsedWeapon.durability = UsedWeapon.durability - removeValue
            
                      if UsedWeapon.durability <= 0 then
                        UsedWeapon.durability = 0
          
                        TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", 0)
        
                        SaveUsedWeaponData()
        
                        UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }
                        RefreshCurrentWeapons()
        
                      else
                        TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", UsedWeapon.durability)
                      end
          
                    end

                  end

                end

              end

            end

          end

        end

      end

    end

    ::END::
    Wait(sleep)

  end

end)

/*
-- We disable the player firing if the left ammo is < 1 because 1 arrow and 1 bullet will always be added to the weapon.
Citizen.CreateThread(function ()

  while true do
    Wait(0)
  
    local PlayerData = TPZInv.getPlayerData()

    if UsedWeapon.weaponId and UsedWeapon.ammoType ~= nil and PlayerData.HasLoadedContents then
  
      local ammo = GetAmmoInPedWeapon(PlayerPedId(), joaat(UsedWeapon.hash))

      if (ammo == 1) and (UsedWeapon.hash == 'WEAPON_BOW' or UsedWeapon.hash == 'WEAPON_BOW_IMPROVED') then
        DisablePlayerFiring(PlayerPedId(), true)
      end
    
    else
      Wait(1000)
    end
  
  end

end)
*/

-- Reloading weapons who have ammo support, such as pistols, rifles, shotguns, revolvers, etc.
Citizen.CreateThread(function ()

  while true do

    local sleep      = 1000
    local player     = PlayerPedId()

    if UsedWeapon.weaponId == nil or UsedWeapon.ammoType == nil then
      goto END
    end

    if not IsFirableWeapon(joaat(UsedWeapon.hash)) then 
      goto END
    end

    if IsFirableWeapon(joaat(UsedWeapon.hash)) then

      sleep = 0 

      if IsControlJustReleased(0, 0xE30CD707) and not UsedWeapon.reloadingWeapon then
  
        local SharedWeapons = TPZInv.getSharedWeapons()
  
        local weaponGroup = GetWeapontypeGroup(UsedWeapon.hash)
        
        if UsedWeapon.hash == "WEAPON_RIFLE_VARMINT" then 
          weaponGroup = tostring(weaponGroup) .. '1'
        end
  
        local getAmmoType = SharedWeapons.AmmoTypes[tostring(weaponGroup)]
  
        if getAmmoType then
  
          local ammoData = SharedWeapons.Ammo[UsedWeapon.ammoType]
          local ammo     = GetAmmoInPedWeapon(PlayerPedId(), joaat(UsedWeapon.hash))
  
          UsedWeapon.reloadingWeapon = true
  
          TriggerServerEvent("tpz_inventory:reloadWeapon", UsedWeapon.weaponId, ammoData.item, ammo, ammoData.maxAmmo)
  
          Wait(1000)
  
        end
  
      end

    end

    ::END::
    Wait(sleep)
  
  end

end)


-- Removing weapons ammo and durability (if the weapon supports it).
Citizen.CreateThread(function ()

  while true do
  
    local sleep = 1200

    if UsedWeapon.weaponId == nil or UsedWeapon.ammoType == nil or UsedWeapon.ammo == 0 then
      goto END
    end

    if not IsFirableWeapon(joaat(UsedWeapon.hash)) and not TPZ.StartsWith(UsedWeapon.hash, 'WEAPON_THROWN') and UsedWeapon.hash ~= 'WEAPON_MELEE_HATCHET' and UsedWeapon.hash ~= 'WEAPON_MELEE_CLEAVER' then 
      goto END
    end

    if IsFirableWeapon(joaat(UsedWeapon.hash)) or TPZ.StartsWith(UsedWeapon.hash, 'WEAPON_THROWN') or UsedWeapon.hash == 'WEAPON_MELEE_HATCHET' or UsedWeapon.hash == 'WEAPON_MELEE_CLEAVER' then 

      sleep = 0

      if IsPedShooting(PlayerPedId()) then
  
        print('1')
        local ammo = GetAmmoInPedWeapon(PlayerPedId(), joaat(UsedWeapon.hash))
  
        if UsedWeapon.ammoType and ammo > 0 then
  
          UsedWeapon.ammo = ammo
  
          TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_AMMO", ammo - 1 )
        end
  
        if TPZ.StartsWith(UsedWeapon.hash, 'WEAPON_THROWN') or UsedWeapon.hash == 'WEAPON_MELEE_HATCHET' or UsedWeapon.hash == 'WEAPON_MELEE_CLEAVER' then
          
          TriggerServerEvent('tpz_inventory:removeWeaponByWeaponId', UsedWeapon.weaponId)
  
          UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }
          RefreshCurrentWeapons()
        end
  
        if UsedWeapon.hash ~= nil then
          local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
          local randomChance       = math.random(1, 100)
  
          if joaat(UsedWeapon.hash) == weaponHash then
  
            local SharedWeapons = TPZInv.getSharedWeapons()
  
            if SharedWeapons.Weapons[UsedWeapon.hash].removeDurabilityValue ~= false then
  
              local WeaponData = SharedWeapons.Weapons[UsedWeapon.hash]
              local removeValue = WeaponData.removeDurabilityValue[1]
  
              if WeaponData.removeDurabilityValue[2] then 
                local randomValue = math.random(WeaponData.removeDurabilityValue[1], WeaponData.removeDurabilityValue[2])
                removeValue = randomValue
              end
  
              if removeValue ~= 0 and randomChance <= WeaponData.removeDurabilityChance then
                UsedWeapon.durability = UsedWeapon.durability - removeValue
    
                if UsedWeapon.durability <= 0 then
                  UsedWeapon.durability = 0
  
                  TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", 0)
  
                  SaveUsedWeaponData()
  
                  UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }
                  RefreshCurrentWeapons()
  
                else
                  TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", UsedWeapon.durability)
                end
  
              end
  
            end
  
          end
  
        end

      end
  
    end

    ::END::
    Wait(sleep)
  
  end
end)


-- Removing lanterns or torches durability
if TPZInv.getSharedWeapons().Options.UsingLanterns then

  -- We don't reset when taking out because the player can abuse it so it will not decrease its durability.
  local CurrentLightDelay = 0

  Citizen.CreateThread(function ()

    while true do
      
      Wait(1000)

      if UsedWeapon.weaponId and UsedWeapon.ammoType == nil and UsedWeapon.ammo <= 1 then

        local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
  
        local isLantern = Citizen.InvokeNative(0x79407D33328286C6, weaponHash)
        local isTorch   = Citizen.InvokeNative(0x506F1DE1BFC75304, weaponHash)
  
        if (isLantern or isTorch ) and joaat(UsedWeapon.hash) == weaponHash then
  
          if TPZInv.getSharedWeapons().Weapons[UsedWeapon.hash].removeDurabilityValue ~= false then
  
            local WeaponData = TPZInv.getSharedWeapons().Weapons[UsedWeapon.hash]
  
            CurrentLightDelay = CurrentLightDelay + 1
  
            -- We check for durability delay on lanterns because lanterns are used while holding.
            if WeaponData.removeDurabilityDelay <= CurrentLightDelay then
  
              CurrentLightDelay = 0
  
              local removeValue = WeaponData.removeDurabilityValue[1]
  
              if WeaponData.removeDurabilityValue[2] then 
                local randomValue = math.random(WeaponData.removeDurabilityValue[1], WeaponData.removeDurabilityValue[2])
                removeValue = randomValue
              end

              if removeValue ~= 0 then
    
                UsedWeapon.durability = UsedWeapon.durability - removeValue
      
                if UsedWeapon.durability <= 0 then
                  UsedWeapon.durability = 0
                
                  TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", 0)
  
                  UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }
                  RefreshCurrentWeapons()
                else
                  TriggerServerEvent("tpz_inventory:setWeaponMetadata", UsedWeapon.weaponId, "SET_DURABILITY", UsedWeapon.durability)
                end
  
              end
  
            end
  
          end
  
        end
  
      end
  
    end
  
  end)

end


-- The specified task is removing the used weapon if this type never goes to the loadout.
-- For example, lanterns when pressing tab or (4), they cannot be used again through loadout, so we remove them from used state.
local getCarriedWeapon = false

Citizen.CreateThread(function ()

  while true do
  
    Wait(1200)

    if UsedWeapon.weaponId and UsedWeapon.ammoType == nil then

      local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 

      if StoredWeaponsList[UsedWeapon.hash] and weaponHash == -1569615261 then
  
        UsedWeapon = { weaponId = nil, weaponObject = nil, hash = nil, ammoType = nil, ammo = 0, name = nil, durability = 0, metadata = {} }
    
        RefreshCurrentWeapons()
        getCarriedWeapon = false
  
      end
  
    end

  end

end)

-- The specified task is for arrows and throwable pickups.
Citizen.CreateThread(function ()

  local pickup_types = {
    ["PICKUP_AMMO_ARROW"]                      = 'AMMO_ARROW',
    ["PICKUP_AMMO_SINGLE_ARROW"]               = 'AMMO_ARROW',
    ["PICKUP_AMMO_SINGLE_ARROW_DYNAMITE"]      = 'AMMO_ARROW_DYNAMITE',
    ["PICKUP_AMMO_SINGLE_ARROW_FIRE"]          = 'AMMO_ARROW_FIRE',
    ["PICKUP_AMMO_SINGLE_ARROW_IMPROVED"]      = 'AMMO_ARROW_IMPROVED',
    ["PICKUP_AMMO_SINGLE_ARROW_POISON"]        = 'AMMO_ARROW_POISON',
    ["PICKUP_AMMO_SINGLE_ARROW_SMALL_GAME"]    = 'AMMO_ARROW_SMALL_GAME',
    ["PICKUP_WEAPON_SINGLE_ARROW"]             = 'AMMO_ARROW',
    ["PICKUP_WEAPON_SINGLE_ARROW_FIRE"]        = 'AMMO_ARROW_FIRE',
    ["PICKUP_WEAPON_THROWN_THROWING_KNIVES"]   = 'WEAPON_THROWN_THROWING_KNIVES',
    ["PICKUP_WEAPON_THROWN_TOMAHAWK"]          = 'WEAPON_THROWN_TOMAHAWK',
    ['PICKUP_WEAPON_THROWN_TOMAHAWK_ANCIENT']  = 'WEAPON_THROWN_TOMAHAWK_ANCIENT',
    ["PICKUP_WEAPON_THROWN_BOLAS"]             = 'WEAPON_THROWN_BOLAS',
    ["PICKUP_WEAPON_MELEE_HATCHET"]            = 'WEAPON_MELEE_HATCHET',
    ["PICKUP_WEAPON_MELEE_HATCHET_DOUBLE_BIT"] = 'WEAPON_MELEE_HATCHET_DOUBLE_BIT',
    ["PICKUP_WEAPON_MELEE_HATCHET_HEWING"]     = 'WEAPON_MELEE_HATCHET_HEWING',
    ["PICKUP_WEAPON_MELEE_HATCHET_HUNTER"]     = 'WEAPON_MELEE_HATCHET_HUNTER',
    ["PICKUP_WEAPON_MELEE_HATCHET_VIKING"]     = 'WEAPON_MELEE_HATCHET_VIKING',
    ["PICKUP_WEAPON_MELEE_CLEAVER"]            = 'PICKUP_WEAPON_MELEE_CLEAVER',
    ["PICKUP_WEAPON_MELEE_CLEAVER_MP"]         = 'PICKUP_WEAPON_MELEE_CLEAVER',
  }

  while true do
    
    Citizen.Wait(0)

    local size = GetNumberOfEvents(0)

    if size > 0 then

      for index = 0, size - 1 do
        local event = GetEventAtIndex(0, index)

        if event == joaat("EVENT_PLAYER_COLLECTED_AMBIENT_PICKUP") then 

          local eventDataSize = 8

          local eventDataStruct = DataView.ArrayBuffer(8 * eventDataSize) -- buffer must be 8*eventDataSize or bigger

          eventDataStruct:SetInt32(8 * 0, 0)		 	-- 8*0 offset for 0 element of eventData
          eventDataStruct:SetInt32(8 * 1, 0)		 	-- 8*0 offset for 0 element of eventData
          eventDataStruct:SetInt32(8 * 2, 0)		 	-- 8*0 offset for 0 element of eventData
          eventDataStruct:SetInt32(8 * 4, 0)		 	-- 8*0 offset for 0 element of eventData
          eventDataStruct:SetInt32(8 * 6, 0)		 	-- 8*0 offset for 0 element of eventData

          local is_data_exists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA,0, index,eventDataStruct:Buffer(),eventDataSize)	-- GET_EVENT_DATA

          if is_data_exists then

            local lootedNameHash         = eventDataStruct:GetInt32(8 * 0)
            local lootedEntityId         = eventDataStruct:GetInt32(8 * 1)
            local looterId               = eventDataStruct:GetInt32(8 * 2)
            local lootedEntityModelHash  = eventDataStruct:GetInt32(8 * 3)
            -- Ensure the player who enacted on the event is the one who must get the rewards

            -- EVENT_PLAYER_COLLECTED_AMBIENT_PICKUP is using PlayerId() instead of PlayerPedId()
            if PlayerId() == looterId then 

              for ambientType, toAmbient in pairs (pickup_types) do

                if joaat(ambientType) == lootedNameHash then 

                  local receive = true

                  if string.find(toAmbient, 'ARROW') and UsedWeapon.weaponId then

                    local ammo = GetAmmoInPedWeapon(PlayerPedId(), joaat(UsedWeapon.hash))

                    if TPZInv.getSharedWeapons().Ammo[toAmbient] then 

                      if ammo < TPZInv.getSharedWeapons().Ammo[toAmbient].maxAmmo then
                        receive = false
                      end

                    else
                      receive = false
                    end
                    
                  end

                  if receive then
                    TriggerServerEvent("tpz_inventory:onThrowableWeaponAmmoAmbientPickup", toAmbient)
                  end

                end

              end

            end

          end

        end

      end

    end
  end

end)

-----------------------------------------------------------
--[[ Weapon Utility Functions  ]]--
-----------------------------------------------------------

GetGuidFromItemId = function (inventoryId, itemData, category, slotId) 
  local outItem = DataView.ArrayBuffer(8 * 13)

  if not itemData then
    itemData = 0
  end

  local success = Citizen.InvokeNative("0x886DFD3E185C8A89", inventoryId, itemData, category, slotId, outItem:Buffer()) --InventoryGetGuidFromItemid
  if success then
    return outItem:Buffer() --Seems to not return anythign diff. May need to pull from native above
  else
    return nil
  end

end

AddWardrobeInventoryItem = function (itemName, slotHash)
  local itemHash = joaat(itemName)
  local addReason = joaat("ADD_REASON_DEFAULT")
  local inventoryId = 1

  -- _ITEMDATABASE_IS_KEY_VALID
  local isValid = Citizen.InvokeNative("0x6D5D51B188333FD1", itemHash, 0) --ItemdatabaseIsKeyValid
  if not isValid then
      return false
  end

  local characterItem = GetGuidFromItemId(inventoryId, nil, joaat("CHARACTER"), 0xA1212100)
  if not characterItem then
      return false
  end

  local wardrobeItem = GetGuidFromItemId(inventoryId, characterItem, joaat("WARDROBE"), 0x3DABBFA7)
  if not wardrobeItem then
      return false 
  end

  local itemData = DataView.ArrayBuffer(8 * 13)

  -- _INVENTORY_ADD_ITEM_WITH_GUID
  local isAdded = Citizen.InvokeNative("0xCB5D11F9508A928D", inventoryId, itemData:Buffer(), wardrobeItem, itemHash, slotHash, 1, addReason);
  if not isAdded then
      return false
  end

  -- _INVENTORY_EQUIP_ITEM_WITH_GUID
  local equipped = Citizen.InvokeNative("0x734311E2852760D0", inventoryId, itemData:Buffer(), true);
  return equipped;
end

GivePlayerWeapon = function (weaponName, attachPoint)
  local addReason = joaat("ADD_REASON_DEFAULT");
  local weaponHash = weaponName;
  local ammoCount = 0;

  -- RequestWeaponAsset
  Citizen.InvokeNative(0x72D4CB5DB927009C, weaponHash, 0, true);
  while not Citizen.InvokeNative(0xFF07CF465F48B830, weaponHash) do Wait(10) end
  -- GIVE_WEAPON_TO_PED
  Citizen.InvokeNative(0x5E3BDDBCB83F3D84, PlayerPedId(), weaponHash, ammoCount, true, false, attachPoint, true, 0.0, 0.0, addReason, true, 0.0, false);
end

function ApplyWeaponComponent(WeaponObject, ComponentHash , slotHash)
  local ComponentModelHash = GetWeaponComponentTypeModel(ComponentHash)

  if not DoesEntityExist(WeaponObject) then
      print("Object Index for weapon does not exist! (Recovery)")
      while not DoesEntityExist(WeaponObject) do 
          Wait(100)
          WeaponObject = GetCurrentPedWeaponEntityIndex(PlayerPedId(), 0)
      end
  end

  local ItemInfoStruct = ItemdatabaseFilloutItemInfo(ComponentHash)
  local ModType = ItemInfoStruct:GetInt32(2 * 8)

  if ModType == joaat("WEAPON_MOD") then

      if not IsModelValid(ComponentModelHash) then
          return
      end

      RequestModel(ComponentModelHash)
      while not HasModelLoaded(ComponentModelHash) do
          Wait(0)
      end

      if not ItemHaveTag(ComponentHash) and not HasWeaponGotWeaponComponent(WeaponObject, ComponentHash) then

          addWeaponInventoryItem(ComponentHash, slotHash)
      else
          print("MOD ALREADY LOADED ")
      end

  elseif ModType == joaat("WEAPON_DECORATION") then
      if not ItemHaveTag(ComponentHash) and not HasWeaponGotWeaponComponent(WeaponObject, ComponentHash) then     
          addWeaponInventoryItem(ComponentHash, slotHash)
      else
          print("DECORATION ALREADY LOADED")
      end
  end
end

function RemoveAllWeaponComponents()
  local WeaponObject = GetCurrentPedWeaponEntityIndex(PlayerPedId(), 0)
  local BoundleInfoStruct = DataView.ArrayBuffer(8 * 8)
  BoundleInfoStruct:SetInt32(0 * 8, 1)
  local WeaponComponentStruct = DataView.ArrayBuffer(8 * 8)
  local BoundleItemId = ItemdatabaseGetBundleId(WeaponHash)
  if BoundleItemId ~= 0 then

      local WeaponComponentsCount = ItemdatabaseGetBundleItemCount(BoundleItemId, BoundleInfoStruct:Buffer())
      local var0 = 0

  if WeaponComponentsCount and WeaponComponentsCount > 0 then

    while var0 < WeaponComponentsCount do
      if ItemdatabaseGetBundleItemInfo(BoundleItemId, BoundleInfoStruct:Buffer(), var0,
        WeaponComponentStruct:Buffer()) then
 
        local ItemInfoStruct = ItemdatabaseFilloutItemInfo(WeaponComponentStruct:GetInt32(0 * 8))
        if not ItemInfoStruct then
          return
        end
 
        local WeaponComponent = ItemInfoStruct:GetInt32(0 * 8)
        local WeaponModType = ItemInfoStruct:GetInt32(2 * 8)
 
        if WeaponModType == joaat("WEAPON_MOD") or WeaponModType == joaat("WEAPON_DECORATION") then
          if HasWeaponGotWeaponComponent(WeaponObject, WeaponComponent) then
            RemoveWeaponComponentFromPed(PlayerPedId(), WeaponComponent, WeaponHash)
          end
        end
      end
      var0 = var0 + 1
    end

  end

  end
  Wait(100)
end

function ItemdatabaseFilloutItemInfo(ItemHash)
  local eventDataStruct = DataView.ArrayBuffer(8 * 8)
  local is_data_exists = Citizen.InvokeNative(0xFE90ABBCBFDC13B2, ItemHash, eventDataStruct:Buffer())
  if not is_data_exists then
      return false
  end
  return eventDataStruct
end

function ItemdatabaseGetBundleId(WeaponHash)
  return Citizen.InvokeNative(0x891A45960B6B768A, WeaponHash)
end

function ItemdatabaseGetBundleItemCount(BoundleItemId, BoundleInfo)
  return Citizen.InvokeNative(0x3332695B01015DF9, BoundleItemId, BoundleInfo)
end

function ItemdatabaseGetBundleItemInfo(BoundleItemId, BoundleInfoStruct, var0, WeaponComponentStruct)
  return Citizen.InvokeNative(0x5D48A77E4B668B57, BoundleItemId, BoundleInfoStruct, var0, WeaponComponentStruct)
end

function ItemHaveTag(ComponentHash)
  return Citizen.InvokeNative(0xFF5FB5605AD56856, ComponentHash, 1844906744, 1120943070)
end

function GetWeaponComponentTypeModel(componentHash)
  return Citizen.InvokeNative(0x59DE03442B6C9598, componentHash)
end

function GiveWeaponComponentToEntity(ped, componentHash, weaponHash, unk)
  return Citizen.InvokeNative(0x74C9090FDD1BB48E, ped, componentHash, weaponHash, unk)
end

function RemoveWeaponComponentFromPed(ped, componentHash, weaponHash)
  return Citizen.InvokeNative(0x19F70C4D80494FF8, ped, componentHash, weaponHash)
end

function RequestWeaponAsset(weaponHash)
  return Citizen.InvokeNative(0x72D4CB5DB927009C, weaponHash , -1 , 0)
end

function ItemdatabaseIsKeyValid(weaponHash, unk)
  return Citizen.InvokeNative(0x6D5D51B188333FD1, weaponHash , unk)
end

function HasWeaponAssetLoaded(weaponHash)
  return Citizen.InvokeNative(0xFF07CF465F48B830, WeaponHash)
end

function InventoryAddItemWithGuid(inventoryId, itemData, parentItem, itemHash, slotHash, amount, addReason)
  return Citizen.InvokeNative(0xCB5D11F9508A928D, inventoryId, itemData, parentItem, itemHash, slotHash, amount, addReason);
 
end

function InventoryEquipItemWithGuid(inventoryId , itemData , bEquipped)
  return Citizen.InvokeNative(0x734311E2852760D0, inventoryId , itemData , bEquipped)
end

function getGuidFromItemId(inventoryId, itemData, category, slotId)
  local outItem = DataView.ArrayBuffer(8 * 13)
  local success = Citizen.InvokeNative(0x886DFD3E185C8A89, inventoryId, itemData and itemData or 0, category, slotId, outItem:Buffer())
  return success and outItem or nil;
end


function addWeaponInventoryItem(itemHash, slotHash)
  local addReason = joaat("ADD_REASON_DEFAULT");
  local inventoryId = 1; -- INVENTORY_SP_PLAYER

  local isValid = ItemdatabaseIsKeyValid(itemHash, 0)
  if not isValid then return false end

  local characterItem = getGuidFromItemId(inventoryId, nil, joaat("CHARACTER"), 0xA1212100);
  if not characterItem then return false end

  local unkStruct = getGuidFromItemId(inventoryId, characterItem:Buffer(), 923904168, -740156546);
  if not unkStruct then return false end

  local weaponItem = getGuidFromItemId(inventoryId, unkStruct:Buffer(), joaat(UsedWeapon.hash), -1591664384);

  if not weaponItem then return false end

  -- WE CANT DO SAME FOR WRAP TINT IDK WHY BUT WORKS WITHOUT THIS 
  local gripItem;
  if slotHash == 0x57575690 then
    gripItem = getGuidFromItemId(inventoryId, weaponItem:Buffer(), joaat("COMPONENT_RIFLE_BOLTACTION_GRIP"), -1591664384);
    if not gripItem then return false end
  end

  local itemData = DataView.ArrayBuffer(8 * 13)

  local isAdded = InventoryAddItemWithGuid(inventoryId, itemData:Buffer(), (slotHash == 0x57575690) and gripItem:Buffer() or weaponItem:Buffer(), itemHash, slotHash, 1, addReason);
  if not isAdded then 
    print('DECORATION NOT LOADED')
    return false 
  end

  local equipped = InventoryEquipItemWithGuid(inventoryId, itemData:Buffer(), true);
  print("LOADED DECORATION")
  return equipped
end

function apply_weapon_component(weapon_component_hash)

	local weapon_component_model_hash = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(weapon_component_hash))

  local playerPed   = PlayerPedId()
  local weaponObject = GetCurrentPedWeaponEntityIndex(playerPed, 0)

	if weapon_component_model_hash and weapon_component_model_hash ~= 0 then

		RequestModel(weapon_component_model_hash)
		local i = 0

		while not HasModelLoaded(weapon_component_model_hash) and i <= 300 do
			i = i + 1
			Wait(100)
		end

		if HasModelLoaded(weapon_component_model_hash) then

        Citizen.InvokeNative(0x74C9090FDD1BB48E, playerPed, joaat(weapon_component_hash), -1, true)
        SetModelAsNoLongerNeeded(weapon_component_model_hash)
        Wait(100)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, playerPed, joaat(weapon_component_hash), true, true, true) -- ApplyShopItemToPed( -- RELOADING THE LIVE MODEL

    end

	else

    Citizen.InvokeNative(0x74C9090FDD1BB48E, playerPed, joaat(weapon_component_hash), -1, true)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, playerPed, joaat(weapon_component_hash), true, true, true) -- ApplyShopItemToPed( -- RELOADING THE LIVE MODEL
  end
end
