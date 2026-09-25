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

local EquippedWeapons   = {}
local HOLDING_WEAPON_ID = 0

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

-- @SaveUsedWeaponData : Is used for exports.
function SaveUsedWeaponData(weaponId)

  if EquippedWeapons[weaponId] then 

    local weaponDirtLevel = Citizen.InvokeNative(0x810E8AE9AFEA7E54, EquippedWeapons[weaponId].weaponObject)

    if weaponDirtLevel then
      TriggerServerEvent("tpz_inventory:setWeaponMetadata", weaponId, 'DIRT_LEVEL', weaponDirtLevel)
    end

    TriggerServerEvent("tpz_inventory:removeDefaultUsedWeaponById", weaponId)

  end

end

-- @ClearUsedWeaponData : Is used for exports.
function ClearUsedWeaponData(weaponId, refresh)

  EquippedWeapons[weaponId] = nil

  if refresh then
    Wait(150)
    RefreshCurrentWeapons()
  end

end

function GetUsedWeaponData()
  return EquippedWeapons[HOLDING_WEAPON_ID]
end

function GetUsedWeaponsData()
  return EquippedWeapons
end

function IsReloadingWeapon()
  return EquippedWeapons[HOLDING_WEAPON_ID].reloadingWeapon
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

  --SaveUsedWeaponData()
  --ClearUsedWeaponData(false)

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
  EquippedWeapons[HOLDING_WEAPON_ID].reloadingWeapon = false
end)

RegisterNetEvent("tpz_weapons:client:reloadWeaponAmmoByWeaponId")
AddEventHandler("tpz_weapons:client:reloadWeaponAmmoByWeaponId", function(weaponId, ammo)

  if EquippedWeapons[weaponId] == nil then
    EquippedWeapons[weaponId].reloadingWeapon = false
    return
  end
  
  if ammo ~= 0 then

    local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), joaat(EquippedWeapons[weaponId].hash))
  
    Citizen.InvokeNative(0x106A811C6D3035F3, PlayerPedId(), joaat(EquippedWeapons[weaponId].ammoType), ammo, 0xCA3454E6)
    EquippedWeapons[weaponId].ammo = currentAmmo + ammo
  
    TriggerServerEvent("tpz_inventory:setWeaponMetadata", EquippedWeapons[weaponId].weaponId, "SET_AMMO", EquippedWeapons[weaponId].ammo)
  
  end

  EquippedWeapons[weaponId].reloadingWeapon = false
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
  if data.defaultWeapons == nil or TPZ.GetTableLength(data.defaultWeapons) <= 0 then
    return
  end

  local exists = false

  for index, content in pairs (PlayerData.Inventory) do

    if content.type == "weapon" and data.defaultWeapons[content.itemId] then 

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
    TriggerServerEvent("tpz_inventory:clearDefaultWeapons")
  end

end

EquipWeapon = function(itemId, hash, ammoType, ammo, label, durability, metadata)

  if durability ~= -1 and durability == 0 then
    SendNotification(nil, Locales['NO_WEAPON_DURABILITY'], 'error' )
    return
  end
  
  local localAmmoType = Citizen.InvokeNative(0x5C2EA6C44F515F34, joaat(string.upper(hash)))
  
  if EquippedWeapons[itemId] then
    SendNotification(nil, Locales['ALREADY_USING'], 'error' )
    return
  end

  local weaponTypeGroup = GetWeaponType(joaat( string.upper(hash) ))
  local longarms  = 0
  local shortarms = 0

  if TPZ.GetTableLength(EquippedWeapons) > 0 then 

    local preventEquip = false 
    
    for _, equippedWeapon in pairs(EquippedWeapons) do 

      local _weaponTypeGroup = GetWeaponType(joaat( equippedWeapon.hash))

      -- Allow two SHORTARM weapons, including two of the exact same revolver.
      -- Other weapon groups keep the original duplicate restriction.
      if joaat(equippedWeapon.hash) == joaat( string.upper(hash))
        and equippedWeapon.group == weaponTypeGroup
        and weaponTypeGroup ~= 'SHORTARM' then

        preventEquip = true
        break
      end

      if _weaponTypeGroup == 'LONGARM' or _weaponTypeGroup == 'SHOTGUN' then 
        longarms = longarms + 1
      end

      if _weaponTypeGroup == 'SHORTARM' then 
        shortarms = shortarms + 1
      end

    end

    if preventEquip then 
      SendNotification(nil, Locales['CANNOT_EQUIP_SAME_WEAPON_TYPE'], 'error' )
      return 
    end

    if (weaponTypeGroup == 'LONGARM' or weaponTypeGroup == 'SHOTGUN') and longarms >= 2 then 
      SendNotification(nil, Locales['CANNOT_EQUIP_MORE_LONGARMS'], 'error' )
      return 
    end

    if (weaponTypeGroup == 'SHORTARM') and shortarms >= 2 then 
      SendNotification(nil, Locales['CANNOT_EQUIP_MORE_SHORTARMS'], 'error' )
      return 
    end

  end
  
  local weaponGroup = GetWeapontypeGroup(joaat( string.upper(hash) ))
  local isWeaponThrowable  = Citizen.InvokeNative(0x30E7C16B12DA8211, joaat( string.upper(hash) ) )
  
  if isWeaponThrowable then
    ammo = 1

  elseif not isWeaponThrowable and ammo == 1 then 
    ammo = 0
  end

  if string.upper(hash) == 'WEAPON_RIFLE_VARMINT' then 
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

  EquippedWeapons[itemId] = {
    weaponId   = itemId,
    hash       = string.upper(hash),
    ammoType   = ammoType,
    ammo       = ammo,
    name       = label,
    durability = durability,
    metadata   = metadata,
    group      = weaponTypeGroup,
  }

  -----------------------------------------------------------
  -- Dual Wield
  -----------------------------------------------------------

  if weaponTypeGroup == 'SHORTARM' then

    local equippedShortarms = 0

    for _, equippedWeapon in pairs(EquippedWeapons) do
      if equippedWeapon.group == 'SHORTARM' then
        equippedShortarms = equippedShortarms + 1
      end
    end

    if equippedShortarms >= 2 then

      -- Enable RedM dual wield.
      Citizen.InvokeNative(
        0x83B8D50EB9446BBA,
        PlayerPedId(),
        true
      )

      -- Add the offhand holster items required by the native weapon system.
      AddWardrobeInventoryItem(
        "CLOTHING_ITEM_M_OFFHAND_000_TINT_004",
        0xF20B6B4A
      )

      AddWardrobeInventoryItem(
        "UPGRADE_OFFHAND_HOLSTER",
        0x39E57B01
      )

    end

  end

  RefreshCurrentWeapons()

  TriggerEvent("tpz_weapons:client:run_weapon_tasks")
end

function RefreshCurrentWeapons()

  local playerPedId = PlayerPedId()

  SetCurrentPedWeapon(playerPedId, joaat("WEAPON_UNARMED"), true, 0, false, false)
  Citizen.InvokeNative(0x1B83C0DEEBCBB214, playerPedId)
  RemoveAllPedWeapons(playerPedId, true, true)

  local shortarmSlot = 0

  for _, usedWeapon in pairs (EquippedWeapons) do

    if usedWeapon.weaponId and usedWeapon.hash ~= nil then
    
      local WeaponHash  = joaat(usedWeapon.hash)
      local addReason   = ADD_REASON_DEFAULT
      local slotHash    = joaat('SLOTID_WEAPON_0')
      local inventoryId = 1
      local slot        = 0

      -------------------------------------------------------
      -- Dual revolver / pistol slots
      --
      -- SLOTID_WEAPON_0 = Right hand
      -- SLOTID_WEAPON_1 = Left hand / offhand
      -------------------------------------------------------

      if usedWeapon.group == 'SHORTARM' then

        if shortarmSlot == 0 then

          slotHash = joaat('SLOTID_WEAPON_0')
          slot = 0

        elseif shortarmSlot == 1 then

          slotHash = joaat('SLOTID_WEAPON_1')
          slot = 1

        end

        shortarmSlot = shortarmSlot + 1

      end
  
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
  
      local characterItem = getGuidFromItemId(inventoryId, nil, joaat("CHARACTER"), 0xA1212100)

      if not characterItem then
        print("featureless")
        return false
      end
  
      local weaponItem = getGuidFromItemId(inventoryId, characterItem:Buffer(), 923904168, -740156546)

      if not weaponItem then
        print("sem armas")
        return false
      end
  
      local itemData = DataView.ArrayBuffer(8 * 13)

      local isAdded = InventoryAddItemWithGuid(
        inventoryId,
        itemData:Buffer(),
        weaponItem:Buffer(),
        WeaponHash,
        slotHash,
        1,
        addReason
      )

      if not isAdded then
        print("Not added")
        return false
      end
  
      local equipped = InventoryEquipItemWithGuid(
        inventoryId,
        itemData:Buffer(),
        true
      )

      if not equipped then
        print("Unable to equip")
        return false
      end
  
      Citizen.InvokeNative(
        0x12FB95FE3D579238,
        playerPedId,
        itemData:Buffer(),
        true,
        slot,
        false,
        false
      )

      usedWeapon.guid = itemData:Buffer()
  
      -- Sets as default
      TriggerServerEvent(
        "tpz_inventory:setDefaultUsedWeapons",
        usedWeapon.weaponId
      )

      local weaponObject = GetCurrentPedWeaponEntityIndex(playerPedId, 0)
  
      if usedWeapon.ammoType then

        Citizen.InvokeNative(
          0x106A811C6D3035F3,
          playerPedId,
          joaat(usedWeapon.ammoType),
          usedWeapon.ammo,
          0xCA3454E6
        )

      else

        SetPedAmmo(
          playerPedId,
          WeaponHash,
          usedWeapon.ammo
        )

      end
  
      if usedWeapon.metadata.dirtLevel then

        Citizen.InvokeNative(
          0x812CE61DEBCAB948,
          weaponObject,
          usedWeapon.metadata.dirtLevel,
          true
        )

      end
  
      if usedWeapon.metadata.components and TPZ.GetTableLength(usedWeapon.metadata.components) > 0 then
  
        RemoveAllWeaponComponents()
  
        -- First we load the weapon components
        -- (not shared ones but based on the weapon hash)
        for name, component in pairs (usedWeapon.metadata.components) do
  
          if model_specific_components[usedWeapon.hash] and model_specific_components[usedWeapon.hash][name] then
    
            local model = Citizen.InvokeNative(
              0x59DE03442B6C9598,
              joaat(component)
            )
    
            if model then
              LoadModel(model)
            end
            
            Citizen.InvokeNative(
              0x74C9090FDD1BB48E,
              playerPedId,
              joaat(component),
              WeaponHash,
              true
            )
  
            if Config.Debug then
              print(
                'Added a component (Model Specific Component): '
                .. name .. ', ' .. component
              )
            end
  
          end
    
        end
  
        local weaponType = GetWeaponType(WeaponHash)
  
        for name, component in pairs (usedWeapon.metadata.components) do
    
          if shared_components[weaponType] and shared_components[weaponType][name] then
    
            local model = Citizen.InvokeNative(
              0x59DE03442B6C9598,
              joaat(component)
            )
    
            if model then
              LoadModel(model)
            end
  
            apply_weapon_component(component)

          end
    
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

CreateThread(function()

  local selectedWeaponForAmmoLoad = 0

  while true do 
    Wait(500)

    local player = PlayerPedId()
    local retval, weaponHash = GetCurrentPedWeapon(player, true, 0, true) 

    if weaponHash == -1569615261 or weaponHash == nil or weaponHash == 0 then 
      HOLDING_WEAPON_ID = 0
      selectedWeaponForAmmoLoad = 0
    else 
      
      for _, equippedWeapon in pairs(EquippedWeapons) do 

        if joaat(equippedWeapon.hash) == weaponHash then 

          HOLDING_WEAPON_ID = equippedWeapon.weaponId

          if selectedWeaponForAmmoLoad == 0 or selectedWeaponForAmmoLoad ~= HOLDING_WEAPON_ID then 

            if equippedWeapon.ammoType then

              local ammo       = GetAmmoInPedWeapon(player, joaat(equippedWeapon.hash))
              local ammoType   = joaat(equippedWeapon.ammoType)
              local targetAmmo = equippedWeapon.ammo
          
              Citizen.InvokeNative(
                  0xB6CFEC32E3742779,
                  player,
                  ammoType,
                  1000,
                  `REMOVE_REASON_DEBUG`
              )
          
              Citizen.InvokeNative(
                  0x106A811C6D3035F3,
                  player,
                  ammoType,
                  targetAmmo,
                  0xCA3454E6
              )

            end

            selectedWeaponForAmmoLoad = HOLDING_WEAPON_ID
          end

          break
        end

      end

    end

  end

end)

-- (!) All tasks are running properly based on the holding weapon, some tasks are based only for lanterns and torches,
-- some other tasks only for knifes, others only for throwables and firing weapons, the tasks will run based on the weapon
-- you are holding for better performance.

-- Knives EntityDamageEvent because there is no Function from Natives that triggers it.
Citizen.CreateThread(function()

  while true do

    local sleep         = 1250
    local isWeaponKnife = Citizen.InvokeNative(0x792E3EF76C911959, weaponHash)

    if HOLDING_WEAPON_ID == 0 or EquippedWeapons[HOLDING_WEAPON_ID] == nil then 
      goto END
    end

    if EquippedWeapons[HOLDING_WEAPON_ID].ammoType == nil and not isWeaponKnife then 
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
  
            local eventDataSize = 9
            local eventDataStruct = DataView.ArrayBuffer(8 * eventDataSize)
  
            eventDataStruct:SetInt32(8 * 1, 0)
            eventDataStruct:SetInt32(8 * 2, 0)
  
            local is_data_exists = Citizen.InvokeNative(
              0x57EC5FA4D4D6AFCA,
              0,
              index,
              eventDataStruct:Buffer(),
              eventDataSize
            )
  
            if is_data_exists then
  
              local attacker   = eventDataStruct:GetInt32(8 * 1)
              local weaponHash = eventDataStruct:GetInt32(8 * 2)

              if PlayerPedId() == attacker then 
  
                local SharedWeapons = TPZInv.getSharedWeapons()

                local usedWeapon = EquippedWeapons[HOLDING_WEAPON_ID]
  
                if SharedWeapons.Weapons[usedWeapon.hash].removeDurabilityValue ~= false then
              
                  local WeaponData   = SharedWeapons.Weapons[usedWeapon.hash]
    
                  local randomChance = math.random(1, 100)
                  local removeValue  = WeaponData.removeDurabilityValue[1]
        
                  if WeaponData.removeDurabilityValue[2] then 
                    local randomValue = math.random(
                      WeaponData.removeDurabilityValue[1],
                      WeaponData.removeDurabilityValue[2]
                    )

                    removeValue = randomValue
                  end
        
                  if removeValue ~= 0 and randomChance <= WeaponData.removeDurabilityChance then
                    usedWeapon.durability = usedWeapon.durability - removeValue
          
                    if usedWeapon.durability <= 0 then
                      usedWeapon.durability = 0
        
                      TriggerServerEvent(
                        "tpz_inventory:setWeaponMetadata",
                        usedWeapon.weaponId,
                        "SET_DURABILITY",
                        0
                      )
      
                      SaveUsedWeaponData(usedWeapon.weaponId)
                      ClearUsedWeaponData(usedWeapon.weaponId, true)
      
                    else
                      TriggerServerEvent(
                        "tpz_inventory:setWeaponMetadata",
                        usedWeapon.weaponId,
                        "SET_DURABILITY",
                        usedWeapon.durability
                      )
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

          local eventDataSize = 3
          local eventDataStruct = DataView.ArrayBuffer(8 * eventDataSize)

          eventDataStruct:SetInt32(8 * 0, 0)
          eventDataStruct:SetInt32(8 * 1, 0)
          eventDataStruct:SetInt32(8 * 2, 0)

          local is_data_exists = Citizen.InvokeNative(
            0x57EC5FA4D4D6AFCA,
            0,
            index,
            eventDataStruct:Buffer(),
            eventDataSize
          )

          if is_data_exists then

            local looterId       = eventDataStruct:GetInt32(8 * 0)
            local lootedEntityId = eventDataStruct:GetInt32(8 * 1)
            local isLootSuccess  = eventDataStruct:GetInt32(8 * 2)

            if PlayerPedId() == looterId and isLootSuccess == 1 then
              
              local model = GetEntityModel(lootedEntityId)

              if model then 

                local SharedWeapons = TPZInv.getSharedWeapons()
  
                if HOLDING_WEAPON_ID ~= 0 and EquippedWeapons[HOLDING_WEAPON_ID] then

                  local usedWeapon = EquippedWeapons[HOLDING_WEAPON_ID]

                  if SharedWeapons.Weapons[usedWeapon.hash] then
                  
                    if SharedWeapons.Weapons[usedWeapon.hash].removeDurabilityValue ~= false then
                
                      local WeaponData   = SharedWeapons.Weapons[usedWeapon.hash]
        
                      local randomChance = math.random(1, 100)
                      local removeValue  = WeaponData.removeDurabilityValue[1]
            
                      if WeaponData.removeDurabilityValue[2] then 
                        local randomValue = math.random(
                          WeaponData.removeDurabilityValue[1],
                          WeaponData.removeDurabilityValue[2]
                        )

                        removeValue = randomValue
                      end
            
                      if removeValue ~= 0 and randomChance <= WeaponData.removeDurabilityChance then
                        usedWeapon.durability = usedWeapon.durability - removeValue
              
                        if usedWeapon.durability <= 0 then
                          usedWeapon.durability = 0
            
                          TriggerServerEvent(
                            "tpz_inventory:setWeaponMetadata",
                            usedWeapon.weaponId,
                            "SET_DURABILITY",
                            0
                          )
          
                          SaveUsedWeaponData(usedWeapon.weaponId)
                          ClearUsedWeaponData(usedWeapon.weaponId, true)
          
                        else
                          TriggerServerEvent(
                            "tpz_inventory:setWeaponMetadata",
                            usedWeapon.weaponId,
                            "SET_DURABILITY",
                            usedWeapon.durability
                          )
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

    end

    ::END::
    Wait(sleep)

  end

end)

-- Reloading weapons who have ammo support, such as pistols, rifles, shotguns, revolvers, etc.
Citizen.CreateThread(function ()

  while true do

    local sleep      = 1000
    local player     = PlayerPedId()

    if HOLDING_WEAPON_ID == 0 or EquippedWeapons[HOLDING_WEAPON_ID] == nil then
      goto END
    end

    if EquippedWeapons[HOLDING_WEAPON_ID].ammoType == nil then 
      goto END
    end

    if not IsFirableWeapon(joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash)) then 
      goto END
    end

    if IsFirableWeapon(joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash)) then

      local usedWeapon = EquippedWeapons[HOLDING_WEAPON_ID]

      sleep = 0 

      if IsControlJustReleased(0, 0xE30CD707) and not usedWeapon.reloadingWeapon then

        local SharedWeapons = TPZInv.getSharedWeapons()
  
        local weaponGroup = GetWeapontypeGroup(usedWeapon.hash)
        
        if usedWeapon.hash == "WEAPON_RIFLE_VARMINT" then 
          weaponGroup = tostring(weaponGroup) .. '1'
        end
  
        local getAmmoType = SharedWeapons.AmmoTypes[tostring(weaponGroup)]
  
        if getAmmoType then
  
          local ammoData = SharedWeapons.Ammo[usedWeapon.ammoType]
          local ammo     = GetAmmoInPedWeapon(PlayerPedId(), joaat(usedWeapon.hash))
  
          usedWeapon.reloadingWeapon = true
  
          TriggerServerEvent(
            "tpz_inventory:reloadWeapon",
            usedWeapon.weaponId,
            ammoData.item,
            ammo,
            ammoData.maxAmmo
          )
  
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

    if HOLDING_WEAPON_ID == 0 or EquippedWeapons[HOLDING_WEAPON_ID] == nil then
      goto END
    end

    if EquippedWeapons[HOLDING_WEAPON_ID].ammoType == nil or EquippedWeapons[HOLDING_WEAPON_ID].ammo == 0 then 
      goto END
    end

    if not IsFirableWeapon(joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash)) and not TPZ.StartsWith(EquippedWeapons[HOLDING_WEAPON_ID].hash, 'WEAPON_THROWN') and EquippedWeapons[HOLDING_WEAPON_ID].hash ~= 'WEAPON_MELEE_HATCHET' and EquippedWeapons[HOLDING_WEAPON_ID].hash ~= 'WEAPON_MELEE_CLEAVER' then 
      goto END
    end

    if IsFirableWeapon(joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash)) or TPZ.StartsWith(EquippedWeapons[HOLDING_WEAPON_ID].hash, 'WEAPON_THROWN') or EquippedWeapons[HOLDING_WEAPON_ID].hash == 'WEAPON_MELEE_HATCHET' or EquippedWeapons[HOLDING_WEAPON_ID].hash == 'WEAPON_MELEE_CLEAVER' then 
      
      local usedWeapon = EquippedWeapons[HOLDING_WEAPON_ID]
  
      sleep = 0

      if IsPedShooting(PlayerPedId()) then

        local ammo = GetAmmoInPedWeapon(PlayerPedId(), joaat(usedWeapon.hash))
  
        if usedWeapon.ammoType and ammo > 0 then
  
          usedWeapon.ammo = ammo
  
          TriggerServerEvent(
            "tpz_inventory:setWeaponMetadata",
            usedWeapon.weaponId,
            "SET_AMMO",
            ammo - 1
          )
        end
  
        if TPZ.StartsWith(usedWeapon.hash, 'WEAPON_THROWN') or usedWeapon.hash == 'WEAPON_MELEE_HATCHET' or usedWeapon.hash == 'WEAPON_MELEE_CLEAVER' then
          
          TriggerServerEvent(
            'tpz_inventory:removeWeaponByWeaponId',
            usedWeapon.weaponId
          )
  
          usedWeapon = {
            weaponId = nil,
            weaponObject = nil,
            hash = nil,
            ammoType = nil,
            ammo = 0,
            name = nil,
            durability = 0,
            metadata = {}
          }

          RefreshCurrentWeapons()
        end
  
        if usedWeapon.hash ~= nil then

          local randomChance = math.random(1, 100)

          local SharedWeapons = TPZInv.getSharedWeapons()

          if SharedWeapons.Weapons[usedWeapon.hash].removeDurabilityValue ~= false then

            local WeaponData = SharedWeapons.Weapons[usedWeapon.hash]
            local removeValue = WeaponData.removeDurabilityValue[1]

            if WeaponData.removeDurabilityValue[2] then 
              local randomValue = math.random(
                WeaponData.removeDurabilityValue[1],
                WeaponData.removeDurabilityValue[2]
              )

              removeValue = randomValue
            end

            if removeValue ~= 0 and randomChance <= WeaponData.removeDurabilityChance then
              usedWeapon.durability = usedWeapon.durability - removeValue
  
              if usedWeapon.durability <= 0 then
                usedWeapon.durability = 0

                TriggerServerEvent(
                  "tpz_inventory:setWeaponMetadata",
                  usedWeapon.weaponId,
                  "SET_DURABILITY",
                  0
                )

                SaveUsedWeaponData(usedWeapon.weaponId)
                ClearUsedWeaponData(usedWeapon.weaponId, true)

              else

                TriggerServerEvent(
                  "tpz_inventory:setWeaponMetadata",
                  usedWeapon.weaponId,
                  "SET_DURABILITY",
                  usedWeapon.durability
                )

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

  local CurrentLightDelay = 0

  Citizen.CreateThread(function ()

    while true do
      
      Wait(1000)

      if HOLDING_WEAPON_ID ~= 0 and EquippedWeapons[HOLDING_WEAPON_ID] then 
        
        if EquippedWeapons[HOLDING_WEAPON_ID].ammoType == nil and EquippedWeapons[HOLDING_WEAPON_ID].ammo <= 1 then

          local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
  
          local isLantern = Citizen.InvokeNative(0x79407D33328286C6, weaponHash)
          local isTorch   = Citizen.InvokeNative(0x506F1DE1BFC75304, weaponHash)
  
          local usedWeapon = EquippedWeapons[HOLDING_WEAPON_ID]
    
          if ( (isLantern or isTorch ) and joaat(usedWeapon.hash) == weaponHash ) or (weaponHash == -1569615261 ) then
            
            local WeaponData = TPZInv.getSharedWeapons().Weapons[usedWeapon.hash]
  
            if TPZInv.getSharedWeapons().Weapons[usedWeapon.hash].removeDurabilityValue ~= false and WeaponData.removeDurabilityDelay then
  
              CurrentLightDelay = CurrentLightDelay + 1
    
              if WeaponData.removeDurabilityDelay <= CurrentLightDelay then
    
                CurrentLightDelay = 0
    
                local removeValue = WeaponData.removeDurabilityValue[1]
    
                if WeaponData.removeDurabilityValue[2] then 
                  local randomValue = math.random(
                    WeaponData.removeDurabilityValue[1],
                    WeaponData.removeDurabilityValue[2]
                  )

                  removeValue = randomValue
                end
  
                if removeValue ~= 0 then
      
                  usedWeapon.durability = usedWeapon.durability - removeValue
        
                  if usedWeapon.durability <= 0 then
                    usedWeapon.durability = 0
                  
                    TriggerServerEvent(
                      "tpz_inventory:setWeaponMetadata",
                      usedWeapon.weaponId,
                      "SET_DURABILITY",
                      0
                    )
    
                    SaveUsedWeaponData(usedWeapon.weaponId)
                    ClearUsedWeaponData(usedWeapon.weaponId, true)

                  else

                    TriggerServerEvent(
                      "tpz_inventory:setWeaponMetadata",
                      usedWeapon.weaponId,
                      "SET_DURABILITY",
                      usedWeapon.durability
                    )

                  end
    
                end
    
              end
    
            end
    
          end

        end
  
      end
  
    end
  
  end)

end


CreateThread(function()

  local IsWeaponLantern = IsWeaponLantern
  local lastLantern = 0

  while true do

    local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 

    if HOLDING_WEAPON_ID ~= 0 and EquippedWeapons[HOLDING_WEAPON_ID] then 
      
      if EquippedWeapons[HOLDING_WEAPON_ID].ammoType == nil and EquippedWeapons[HOLDING_WEAPON_ID].ammo <= 1 then
  
        local retval, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
        local isLantern = Citizen.InvokeNative(0x79407D33328286C6, weaponHash)
  
        if isLantern then 
          lastLantern = joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash)
        end
  
        if lastLantern ~= 0 and not isLantern then
          SetCurrentPedWeapon(PlayerPedId(), lastLantern, true, 12, false, false)
          lastLantern = 0
        end
        
      end

    end

    Wait(500)

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
    ["PICKUP_WEAPON_MELEE_CLEAVER"]            = 'WEAPON_MELEE_CLEAVER',
    ["PICKUP_WEAPON_MELEE_CLEAVER_MP"]         = 'WEAPON_MELEE_CLEAVER',
  }

  while true do
    
    Citizen.Wait(0)

    local size = GetNumberOfEvents(0)

    if size > 0 then

      for index = 0, size - 1 do
        local event = GetEventAtIndex(0, index)

        if event == joaat("EVENT_PLAYER_COLLECTED_AMBIENT_PICKUP") then 

          local eventDataSize = 8

          local eventDataStruct = DataView.ArrayBuffer(8 * eventDataSize)

          eventDataStruct:SetInt32(8 * 0, 0)
          eventDataStruct:SetInt32(8 * 1, 0)
          eventDataStruct:SetInt32(8 * 2, 0)
          eventDataStruct:SetInt32(8 * 4, 0)
          eventDataStruct:SetInt32(8 * 6, 0)

          local is_data_exists = Citizen.InvokeNative(
            0x57EC5FA4D4D6AFCA,
            0,
            index,
            eventDataStruct:Buffer(),
            eventDataSize
          )

          if is_data_exists then

            local lootedNameHash         = eventDataStruct:GetInt32(8 * 0)
            local lootedEntityId         = eventDataStruct:GetInt32(8 * 1)
            local looterId               = eventDataStruct:GetInt32(8 * 2)
            local lootedEntityModelHash  = eventDataStruct:GetInt32(8 * 3)

            if PlayerId() == looterId then 

              for ambientType, toAmbient in pairs (pickup_types) do

                if joaat(ambientType) == lootedNameHash then 

                  local receive = true

                  if string.find(toAmbient, 'ARROW') and EquippedWeapons[HOLDING_WEAPON_ID] then

                    local ammo = GetAmmoInPedWeapon(
                      PlayerPedId(),
                      joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash)
                    )

                    if TPZInv.getSharedWeapons().Ammo[toAmbient] then 

                      if ammo < TPZInv.getSharedWeapons().Ammo[toAmbient].maxAmmo then
                        receive = false
                      end

                    else
                      receive = false
                    end
                    
                  end

                  if receive then
                    TriggerServerEvent(
                      "tpz_inventory:onThrowableWeaponAmmoAmbientPickup",
                      toAmbient
                    )
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

  local success = Citizen.InvokeNative(
    "0x886DFD3E185C8A89",
    inventoryId,
    itemData,
    category,
    slotId,
    outItem:Buffer()
  )

  if success then
    return outItem:Buffer()
  else
    return nil
  end

end

AddWardrobeInventoryItem = function (itemName, slotHash)

  local itemHash = joaat(itemName)
  local addReason = joaat("ADD_REASON_DEFAULT")
  local inventoryId = 1

  local isValid = Citizen.InvokeNative(
    "0x6D5D51B188333FD1",
    itemHash,
    0
  )

  if not isValid then
    return false
  end

  local characterItem = GetGuidFromItemId(
    inventoryId,
    nil,
    joaat("CHARACTER"),
    0xA1212100
  )

  if not characterItem then
    return false
  end

  local wardrobeItem = GetGuidFromItemId(
    inventoryId,
    characterItem,
    joaat("WARDROBE"),
    0x3DABBFA7
  )

  if not wardrobeItem then
    return false 
  end

  local itemData = DataView.ArrayBuffer(8 * 13)

  local isAdded = Citizen.InvokeNative(
    "0xCB5D11F9508A928D",
    inventoryId,
    itemData:Buffer(),
    wardrobeItem,
    itemHash,
    slotHash,
    1,
    addReason
  )

  if not isAdded then
    return false
  end

  local equipped = Citizen.InvokeNative(
    "0x734311E2852760D0",
    inventoryId,
    itemData:Buffer(),
    true
  )

  return equipped
end

GivePlayerWeapon = function (weaponName, attachPoint)

  local addReason = joaat("ADD_REASON_DEFAULT")
  local weaponHash = weaponName
  local ammoCount = 0

  Citizen.InvokeNative(
    0x72D4CB5DB927009C,
    weaponHash,
    0,
    true
  )

  while not Citizen.InvokeNative(
    0xFF07CF465F48B830,
    weaponHash
  ) do
    Wait(10)
  end

  Citizen.InvokeNative(
    0x5E3BDDBCB83F3D84,
    PlayerPedId(),
    weaponHash,
    ammoCount,
    true,
    false,
    attachPoint,
    true,
    0.0,
    0.0,
    addReason,
    true,
    0.0,
    false
  )
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

    local WeaponComponentsCount = ItemdatabaseGetBundleItemCount(
      BoundleItemId,
      BoundleInfoStruct:Buffer()
    )

    local var0 = 0

    if WeaponComponentsCount and WeaponComponentsCount > 0 then

      while var0 < WeaponComponentsCount do

        if ItemdatabaseGetBundleItemInfo(
          BoundleItemId,
          BoundleInfoStruct:Buffer(),
          var0,
          WeaponComponentStruct:Buffer()
        ) then
 
          local ItemInfoStruct = ItemdatabaseFilloutItemInfo(
            WeaponComponentStruct:GetInt32(0 * 8)
          )

          if not ItemInfoStruct then
            return
          end
 
          local WeaponComponent = ItemInfoStruct:GetInt32(0 * 8)
          local WeaponModType = ItemInfoStruct:GetInt32(2 * 8)
 
          if WeaponModType == joaat("WEAPON_MOD") or WeaponModType == joaat("WEAPON_DECORATION") then

            if HasWeaponGotWeaponComponent(
              WeaponObject,
              WeaponComponent
            ) then

              RemoveWeaponComponentFromPed(
                PlayerPedId(),
                WeaponComponent,
                WeaponHash
              )

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

  local is_data_exists = Citizen.InvokeNative(
    0xFE90ABBCBFDC13B2,
    ItemHash,
    eventDataStruct:Buffer()
  )

  if not is_data_exists then
      return false
  end

  return eventDataStruct
end

function ItemdatabaseGetBundleId(WeaponHash)
  return Citizen.InvokeNative(
    0x891A45960B6B768A,
    WeaponHash
  )
end

function ItemdatabaseGetBundleItemCount(BoundleItemId, BoundleInfo)
  return Citizen.InvokeNative(
    0x3332695B01015DF9,
    BoundleItemId,
    BoundleInfo
  )
end

function ItemdatabaseGetBundleItemInfo(
  BoundleItemId,
  BoundleInfoStruct,
  var0,
  WeaponComponentStruct
)

  return Citizen.InvokeNative(
    0x5D48A77E4B668B57,
    BoundleItemId,
    BoundleInfoStruct,
    var0,
    WeaponComponentStruct
  )
end

function ItemHaveTag(ComponentHash)
  return Citizen.InvokeNative(
    0xFF5FB5605AD56856,
    ComponentHash,
    1844906744,
    1120943070
  )
end

function GetWeaponComponentTypeModel(componentHash)
  return Citizen.InvokeNative(
    0x59DE03442B6C9598,
    componentHash
  )
end

function GiveWeaponComponentToEntity(ped, componentHash, weaponHash, unk)
  return Citizen.InvokeNative(
    0x74C9090FDD1BB48E,
    ped,
    componentHash,
    weaponHash,
    unk
  )
end

function RemoveWeaponComponentFromPed(ped, componentHash, weaponHash)
  return Citizen.InvokeNative(
    0x19F70C4D80494FF8,
    ped,
    componentHash,
    weaponHash
  )
end

function RequestWeaponAsset(weaponHash)
  return Citizen.InvokeNative(
    0x72D4CB5DB927009C,
    weaponHash,
    -1,
    0
  )
end

function ItemdatabaseIsKeyValid(weaponHash, unk)
  return Citizen.InvokeNative(
    0x6D5D51B188333FD1,
    weaponHash,
    unk
  )
end

function HasWeaponAssetLoaded(weaponHash)
  return Citizen.InvokeNative(
    0xFF07CF465F48B830,
    WeaponHash
  )
end

function InventoryAddItemWithGuid(
  inventoryId,
  itemData,
  parentItem,
  itemHash,
  slotHash,
  amount,
  addReason
)

  return Citizen.InvokeNative(
    0xCB5D11F9508A928D,
    inventoryId,
    itemData,
    parentItem,
    itemHash,
    slotHash,
    amount,
    addReason
  )
 
end

function InventoryEquipItemWithGuid(
  inventoryId,
  itemData,
  bEquipped
)

  return Citizen.InvokeNative(
    0x734311E2852760D0,
    inventoryId,
    itemData,
    bEquipped
  )
end

function getGuidFromItemId(
  inventoryId,
  itemData,
  category,
  slotId
)

  local outItem = DataView.ArrayBuffer(8 * 13)

  local success = Citizen.InvokeNative(
    0x886DFD3E185C8A89,
    inventoryId,
    itemData and itemData or 0,
    category,
    slotId,
    outItem:Buffer()
  )

  return success and outItem or nil
end


function addWeaponInventoryItem(itemHash, slotHash)

  local addReason = joaat("ADD_REASON_DEFAULT")
  local inventoryId = 1

  local isValid = ItemdatabaseIsKeyValid(itemHash, 0)

  if not isValid then
    return false
  end

  local characterItem = getGuidFromItemId(
    inventoryId,
    nil,
    joaat("CHARACTER"),
    0xA1212100
  )

  if not characterItem then
    return false
  end

  local unkStruct = getGuidFromItemId(
    inventoryId,
    characterItem:Buffer(),
    923904168,
    -740156546
  )

  if not unkStruct then
    return false
  end

  local weaponItem = getGuidFromItemId(
    inventoryId,
    unkStruct:Buffer(),
    joaat(EquippedWeapons[HOLDING_WEAPON_ID].hash),
    -1591664384
  );

  if not weaponItem then
    return false
  end

  local gripItem

  if slotHash == 0x57575690 then

    gripItem = getGuidFromItemId(
      inventoryId,
      weaponItem:Buffer(),
      joaat("COMPONENT_RIFLE_BOLTACTION_GRIP"),
      -1591664384
    )

    if not gripItem then
      return false
    end

  end

  local itemData = DataView.ArrayBuffer(8 * 13)

  local isAdded = InventoryAddItemWithGuid(
    inventoryId,
    itemData:Buffer(),
    (slotHash == 0x57575690) and gripItem:Buffer() or weaponItem:Buffer(),
    itemHash,
    slotHash,
    1,
    addReason
  )

  if not isAdded then 
    print('DECORATION NOT LOADED')
    return false 
  end

  local equipped = InventoryEquipItemWithGuid(
    inventoryId,
    itemData:Buffer(),
    true
  )

  print("LOADED DECORATION")

  return equipped
end

function apply_weapon_component(weapon_component_hash)

  local weapon_component_model_hash = Citizen.InvokeNative(
    0x59DE03442B6C9598,
    joaat(weapon_component_hash)
  )

  local playerPed = PlayerPedId()
  local weaponObject = GetCurrentPedWeaponEntityIndex(
    playerPed,
    0
  )

  if weapon_component_model_hash and weapon_component_model_hash ~= 0 then

    RequestModel(weapon_component_model_hash)

    local i = 0

    while not HasModelLoaded(weapon_component_model_hash) and i <= 300 do
      i = i + 1
      Wait(100)
    end

    if HasModelLoaded(weapon_component_model_hash) then

      Citizen.InvokeNative(
        0x74C9090FDD1BB48E,
        playerPed,
        joaat(weapon_component_hash),
        -1,
        true
      )

      SetModelAsNoLongerNeeded(weapon_component_model_hash)

      Wait(100)

      Citizen.InvokeNative(
        0xD3A7B003ED343FD9,
        playerPed,
        joaat(weapon_component_hash),
        true,
        true,
        true
      )

    end

  else

    Citizen.InvokeNative(
      0x74C9090FDD1BB48E,
      playerPed,
      joaat(weapon_component_hash),
      -1,
      true
    )

    Citizen.InvokeNative(
      0xD3A7B003ED343FD9,
      playerPed,
      joaat(weapon_component_hash),
      true,
      true,
      true
    )

  end
end

if Config.DisableSprintWhileAiming then

  Citizen.CreateThread(function()

    while true do
      
      local sleep = 1000

      if IsPlayerFreeAiming(PlayerId()) then
        sleep = 0
        DisableControlAction(0, 0x8FFC75D6, true) 
      end

      Wait(sleep)

    end

  end)

end

-- Damage Modifiers
if Config.WeaponDamageModifiers then

  Citizen.CreateThread(function()

    local RegisteredWeaponModifiers = {}
    local LastWeapon = nil

    for _, v in ipairs(Config.WeaponDamages) do
      local hash = joaat(v.Name)
      RegisteredWeaponModifiers[hash] = {
        Damage = v.Damage,
        Name = v.Name
      }
    end
    
    while true do
      
      Wait(1000) 

      local ped = PlayerPedId()
      local _, currentWeapon = GetCurrentPedWeapon(ped)

      if currentWeapon ~= LastWeapon then
        
        local weaponData      = RegisteredWeaponModifiers[currentWeapon] 
        local currentModifier = 1.0
        local weaponLabel     = "Unknown Weapon"

        if weaponData then
          currentModifier = weaponData.Damage
          weaponLabel = weaponData.Name
        end

        Citizen.InvokeNative(
          0xD04AD186CE8BB129,
          PlayerId(),
          currentWeapon,
          currentModifier
        ) 

        if Config.Debug and weaponData then
          local message = string.format(
            "Weapon: %s | Damage Modifier: %.2fx",
            weaponLabel,
            currentModifier
          )

          print(message)
        end

        LastWeapon = currentWeapon
        
      end
      
    end

  end)

end
