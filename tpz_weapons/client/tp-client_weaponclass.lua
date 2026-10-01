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

-- EquippedWeapons must always mirror the ped: the inventory shows a weapon
-- as equipped, and refuses to equip it again, purely from this list. These
-- guard the moments the ped loses its weapons behind the list's back.
local ArsenalLoading  = false -- a load or a rebuild is putting weapons on
local ArsenalRestart  = false -- the ped changed while that was running
local DeathWindow     = false -- dead, until the resurrection has settled
local LastRespawnAt   = 0     -- a respawn clears the weapons by design
local PendingList     = nil   -- a load a death cut short, for the revive
local SessionReady    = false -- a character is in the world (no rebuilds before)
local SpawnLoad       = nil   -- the black-screen load: 'pending', 'done' or nil

-- shortarms currently registered in the guid slots, ordered by slot
local function RegisteredShortarms()
  local list = {}
  for _, w in pairs(EquippedWeapons) do
    if w.group == 'SHORTARM' and w.guid then list[#list + 1] = w end
  end
  table.sort(list, function(a, b) return (a.slot or 0) < (b.slot or 0) end)
  return list
end

-- every weapon leaves the ped AND the list; tellServer also clears the
-- character's saved equipped weapons, so the next login agrees
local function ForgetAllWeapons(tellServer)
  EquippedWeapons   = {}
  HOLDING_WEAPON_ID = 0
  PendingList       = nil

  local ped = PlayerPedId()
  SetCurrentPedWeapon(ped, joaat("WEAPON_UNARMED"), true, 0, false, false)
  SetCurrentPedWeapon(ped, joaat("WEAPON_UNARMED"), true, 1, false, false)
  Citizen.InvokeNative(0x1B83C0DEEBCBB214, ped)
  RemoveAllPedWeapons(ped, true, true)

  if tellServer then
    TriggerServerEvent("tpz_inventory:clearDefaultWeapons")
  end
end

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

  -- incremental removal: only THIS weapon leaves the body. The rest of the
  -- arsenal is never touched, so nothing else can vanish or replay a draw.
  local rec = EquippedWeapons[weaponId]
  EquippedWeapons[weaponId] = nil

  if rec and rec.hash then

    local playerPedId = PlayerPedId()

    if rec.guid then
      Citizen.InvokeNative(0x3E4E811480B3AE79, 1, rec.guid, 1, ADD_REASON_DEFAULT)

      -- removal by hash hits EVERY copy of that model: with a twin of the
      -- same revolver still equipped, only the guid item may be removed
      local sameHashMate = false
      for _, w in pairs(EquippedWeapons) do
        if w.guid and joaat(w.hash) == joaat(rec.hash) then
          sameHashMate = true
          break
        end
      end
      if not sameHashMate then
        RemoveWeaponFromPed(playerPedId, joaat(rec.hash), true, 0)
      end

      -- a surviving offhand gun moves up to the main slot
      local mates = RegisteredShortarms()
      if #mates == 1 and mates[1].slot == 1 then
        local characterItem = getGuidFromItemId(1, nil, joaat("CHARACTER"), 0xA1212100)
        local weaponItem = characterItem and getGuidFromItemId(1, characterItem:Buffer(), 923904168, -740156546)
        if weaponItem then
          local out = DataView.ArrayBuffer(8 * 13)
          if Citizen.InvokeNative(0xDCCAA7C3BFD88862, 1, mates[1].guid, weaponItem:Buffer(), joaat('SLOTID_WEAPON_0'), 1, out:Buffer()) then
            mates[1].guid = out:Buffer()
            mates[1].slot = 0
            -- the move only re-files the gun: if it is still out in the
            -- LEFT hand it goes to the right one with its new slot; a
            -- holstered gun stays holstered
            local _, leftHash = GetCurrentPedWeapon(playerPedId, true, 1, false)
            if leftHash == joaat(mates[1].hash) then
              Citizen.InvokeNative(0x12FB95FE3D579238, playerPedId, mates[1].guid, true, 0, false, false)
            end
          end
        end
      end
    else
      RemoveWeaponFromPed(playerPedId, joaat(rec.hash), true, 0)
    end

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

  SetCurrentPedWeapon(PlayerPedId(), joaat("WEAPON_UNARMED"), true, 0, false, false)

  Citizen.InvokeNative(0x1B83C0DEEBCBB214, PlayerPedId())
  RemoveAllPedWeapons(PlayerPedId(), true, true)

end)

-- @tpz_core:isPlayerRespawned : When player is respawning after death - not char select, we clear the weapon from hands and all data.
RegisterNetEvent("tpz_core:isPlayerRespawned")
AddEventHandler("tpz_core:isPlayerRespawned", function()

  -- the ped is stripped, and the list and the server are told so: a list
  -- left full would keep the inventory calling the weapons equipped and
  -- refusing to equip them again
  LastRespawnAt = GetGameTimer()
  ForgetAllWeapons(true)
end)

-- sent by tpz_core when a death takes the inventory contents away
RegisterNetEvent("tpz_inventory:clearEquippedWeapons")
AddEventHandler("tpz_inventory:clearEquippedWeapons", function()
  ForgetAllWeapons(true)
end)

-- every resurrection, revive or respawn, ends here. A respawn follows at
-- once and clears the list; after that moment the watch reopens, finds
-- the new ped the skin reload made, and a revive gets its weapons back.
AddEventHandler("tpz_core:onPlayerRespawn", function()
  CreateThread(function()
    Wait(1000)
    DeathWindow = false
  end)
end)


-- @tpz_core:isPlayerReady : After selecting a character, we request the player inventory contents.
AddEventHandler("tpz_core:isPlayerReady", function(newChar)

  -- If devmode is enabled, we are not running the following code since it already does.
  if Config.DevMode then
    return
  end

  LoadJoinResults()

  -- the black-screen load at first spawn has normally done it already;
  -- this one only runs when that could not (arrived dead, brand new, or
  -- no answer from the server)
  while SpawnLoad == 'pending' do
    Wait(100)
  end

  if SpawnLoad == 'done' then
    return
  end

  ReloadWeaponsOnCharacterSelect(true)

end)

if Config.DevMode then

  Citizen.CreateThread(function()
    Wait(2000)

    LoadJoinResults()

    while SpawnLoad == 'pending' do
      Wait(100)
    end
    
    if SpawnLoad == 'done' then
      return
    end

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


RegisterNetEvent("tpz_weapons:client:removeEquippedWeaponById")
AddEventHandler("tpz_weapons:client:removeEquippedWeaponById", function(weaponId)

  if EquippedWeapons[weaponId] == nil then 
    return 
  end

  EquippedWeapons[weaponId] = nil
end)

-----------------------------------------------------------
--[[ Weapon Functions  ]]--
-----------------------------------------------------------

-- long arms and blades first, sidearms last, each in a fixed order
local function ArsenalOrder(a, b)
  local sa, sb = a.group == 'SHORTARM', b.group == 'SHORTARM'
  if sa ~= sb then return sb end
  return tostring(a.itemId) < tostring(b.itemId)
end

-- puts the list on the ped in one go, no draws: long arms go straight
-- onto the back, blades into their sheaths, and the sidearms come last.
-- holdSidearms leaves them drawn in the hands (both, when there are two);
-- otherwise everything ends holstered. If the ped is swapped mid-way, the
-- whole list starts over on the new one; if it dies, the list waits for
-- the revive.
local function PutOnArsenal(list, holdSidearms)

  ArsenalLoading = true
  ArsenalRestart = true

  while ArsenalRestart and not DeathWindow do

    ArsenalRestart = false

    -- the ped starts empty, and so does the list: each weapon is claimed
    -- again only as it really lands
    EquippedWeapons   = {}
    HOLDING_WEAPON_ID = 0

    local ped = PlayerPedId()

    for i, w in ipairs(list) do
      if IsEntityDead(PlayerPedId()) then
        DeathWindow = true
      end
      if PlayerPedId() ~= ped or DeathWindow then
        ArsenalRestart = true
        break
      end
      EquipWeapon(w.itemId, w.hash, w.ammoType, w.ammo, w.label, w.durability, w.metadata, true)
    end

    if ArsenalRestart then
      -- let the new ped hold still before starting over
      Wait(1000)
    elseif not holdSidearms then
      -- the sidearms were materialized in the hands: BOTH go away
      Citizen.InvokeNative(0x94A3C1B804D291EC, PlayerPedId(), false, false, false, false)
      SetCurrentPedWeapon(PlayerPedId(), joaat("WEAPON_UNARMED"), true, 0, false, false)
    end
  end

  if DeathWindow then
    PendingList = list
  end

  ArsenalLoading = false
end

-- the list's weapons, back onto a new ped (skin reload, revive, another
-- script's model change): the new ped carries none of them
function RebuildArsenal()

  if ArsenalLoading then
    ArsenalRestart = true
    return
  end

  local list = PendingList
  PendingList = nil

  if not list then
    list = {}
    for _, w in pairs(EquippedWeapons) do
      list[#list + 1] = {
        itemId = w.weaponId, hash = w.hash, ammoType = w.ammoType, ammo = w.ammo,
        label = w.name, durability = w.durability, metadata = w.metadata,
        group = w.group,
      }
    end
  end

  if #list == 0 then return end

  table.sort(list, ArsenalOrder)

  -- mid-game the player is watching: everything ends holstered
  PutOnArsenal(list, false)
end

-- LOGIN, inside TPZ's own black screen: tpz_characters fades the screen
-- out before it sets the model, and tpz_core keeps it black for about five
-- seconds after this event (stand still 3s, teleport, 2s) before it fades
-- in. The saved weapons go on inside that stretch, so the character
-- appears already wearing them. The inventory is not loaded yet here, so
-- the list comes from this resource's own server callback, read from the
-- database. A character arriving dead or brand new is left to the regular
-- load at isPlayerReady.
function LoadJoinResults()

  SpawnLoad    = 'pending'
  SessionReady = true

  local attempts    = 0
  local maxAttempts = 10
  local success     = true 
  

  while exports.tpz_core:getCoreAPI().GetPlayerClientData() == nil do 
    Wait(500)

    attempts = attempts + 1 

    if attempts == maxAttempts then 
      success = false
      break 
    end

  end

  if not success then 
    return 
  end

  attempts    = 0
  maxAttempts = 10
  success     = true 

  while not TPZInv.getPlayerData().HasLoadedContents do

    Wait(500)

    attempts = attempts + 1 

    if attempts == maxAttempts then 
      success = false
      break 
    end

  end

  if not success then 
    return 
  end

  /*
  local saved, answered = nil, false
  TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_weapons:getSavedArsenal", function(result)
    saved, answered = result, true
  end)

  local waited = 0
  while not answered and waited < 5000 do
    Wait(50)
    waited = waited + 50
  end

  if saved == nil then
    SpawnLoad = nil
    return
  end

  SpawnLoad = 'done'*/


  local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

  -- We avoid any kind of looping since there is no default weapon set.
  if data.defaultWeapons == nil or TPZ.GetTableLength(data.defaultWeapons) <= 0 then
    return
  end

  local PlayerData    = TPZInv.getPlayerData()
  local SharedWeapons = TPZInv.getSharedWeapons()
  local list          = {}

  for index, content in pairs (PlayerData.Inventory) do

    if content.type == "weapon" and data.defaultWeapons[content.itemId] then 

      local upper    = string.upper(content.item)
      local meta     = content.metadata or {}
      local ammoType = meta.ammoType
  
      -- resolved here the way EquipWeapon would, so EquipWeapon never asks
      -- the server to store it: the server's inventory is not loaded yet
      if ammoType == nil then
        local group = GetWeapontypeGroup(joaat(upper))
        if upper == 'WEAPON_RIFLE_VARMINT' then
          group = tostring(group) .. '1'
        end
        local types = SharedWeapons.AmmoTypes[tostring(group)]
        ammoType = types and types[1] or nil
      end
  
      local shared = SharedWeapons.Weapons[upper]
  
      list[#list + 1] = {
        itemId     = content.itemId,
        hash       = content.item,
        ammoType   = ammoType,
        ammo       = meta.ammo,
        label      = shared and shared.label or content.item,
        durability = meta.durability,
        metadata   = meta,
        group      = GetWeaponType(joaat(upper)),
      }

    end

  end


  if #list == 0 then
    return
  end

  RemoveAllPedWeapons(PlayerPedId(), true, true)
  table.sort(list, ArsenalOrder)

  local ok, err = pcall(PutOnArsenal, list, true)
  if not ok then
    print("saved weapons load failed: " .. tostring(err))
  end
end

-- the saved weapons of the character that just arrived
local function LoadSavedWeapons(startedAt, holdSidearms)
  
  local attempts    = 0
  local maxAttempts = 10
  local success     = true 

  while exports.tpz_core:getCoreAPI().GetPlayerClientData() == nil do 
    Wait(500)

    attempts = attempts + 1 

    if attempts == maxAttempts then 
      success = false
      break 
    end

  end

  if not success then 
    return 
  end

  attempts    = 0
  maxAttempts = 10
  success     = true 

  while not TPZInv.getPlayerData().HasLoadedContents do

    Wait(500)

    attempts = attempts + 1 

    if attempts == maxAttempts then 
      success = false
      break 
    end

  end

  if not success then 
    return 
  end

  -- a character that logged out dead dies again on arrival: wait for the
  -- resurrection. A respawn clears the weapons by design, so nothing loads.
  while DeathWindow or IsEntityDead(PlayerPedId()) do
    Wait(500)
  end
  if LastRespawnAt > startedAt then
    return
  end

  local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

  -- We avoid any kind of looping since there is no default weapon set.
  if data.defaultWeapons == nil or TPZ.GetTableLength(data.defaultWeapons) <= 0 then
    return
  end

  -- a fresh start: the ped begins empty, whatever an earlier character in
  -- this session left behind (the load empties the list itself)
  RemoveAllPedWeapons(PlayerPedId(), true, true)

  local list = {}

  -- fetched now, after the contents are in: a fresh copy, never a stale one
  for index, content in pairs (TPZInv.getInventoryContents() or {}) do

    if content.type == "weapon" and data.defaultWeapons[content.itemId] then

      list[#list + 1] = {
        itemId     = content.itemId,
        hash       = content.item,
        ammoType   = content.metadata.ammoType,
        ammo       = content.metadata.ammo,
        label      = content.label,
        durability = content.metadata.durability,
        metadata   = content.metadata,
        group      = GetWeaponType(joaat(string.upper(content.item))),
      }

    end

  end


  -- If the default weapon does not exist, we set it as 0.
  if #list == 0 then
    TriggerServerEvent("tpz_inventory:clearDefaultWeapons")
    return
  end

  table.sort(list, ArsenalOrder)
  PutOnArsenal(list, holdSidearms)
end

-- atLogin: the character appears with the long arms on the back, the
-- blades sheathed and the sidearms in the hands
function ReloadWeaponsOnCharacterSelect(atLogin)

  local startedAt = GetGameTimer()

  SessionReady = true

  local ok, err = pcall(LoadSavedWeapons, startedAt, atLogin)
  if not ok then
    print("saved weapons load failed: " .. tostring(err))
  end
end

-- placeQuietly (loads only): the weapon goes straight to its place on the
-- body, no draw. A player equipping from the inventory always gets the draw.
EquipWeapon = function(itemId, hash, ammoType, ammo, label, durability, metadata, placeQuietly)

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

  if not EquipSingleWeapon(EquippedWeapons[itemId], placeQuietly) then
    -- it never reached the body: the list must not claim it, or the
    -- inventory shows it equipped and refuses to equip it again
    EquippedWeapons[itemId] = nil
    return
  end

  TriggerEvent("tpz_weapons:client:run_weapon_tasks")
end

-- ammo, dirt and components for the weapon currently in the hands
local function ApplyHeldState(rec)

  local playerPedId = PlayerPedId()
  local WeaponHash  = joaat(rec.hash)

  if rec.ammoType then
    Citizen.InvokeNative(0x106A811C6D3035F3, playerPedId, joaat(rec.ammoType), rec.ammo, 0xCA3454E6)
  else
    SetPedAmmo(playerPedId, WeaponHash, rec.ammo)
  end

  local weaponObject = GetCurrentPedWeaponEntityIndex(playerPedId, 0)

  if rec.metadata.dirtLevel then
    Citizen.InvokeNative(0x812CE61DEBCAB948, weaponObject, rec.metadata.dirtLevel, true)
  end

  if rec.metadata.components and TPZ.GetTableLength(rec.metadata.components) > 0 then
    RemoveAllWeaponComponents()
    for name, component in pairs(rec.metadata.components) do
      if model_specific_components[rec.hash] and model_specific_components[rec.hash][name] then
        local model = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(component))
        if model then LoadModel(model) end
        Citizen.InvokeNative(0x74C9090FDD1BB48E, playerPedId, joaat(component), WeaponHash, true)
      end
    end
    local weaponType = GetWeaponType(WeaponHash)
    for name, component in pairs(rec.metadata.components) do
      if shared_components[weaponType] and shared_components[weaponType][name] then
        local model = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(component))
        if model then LoadModel(model) end
        apply_weapon_component(component)
      end
    end
  end

end

-- incremental equip: adds ONE weapon to the body and lets the engine play
-- the transition. The rest of the arsenal is never rebuilt.
function EquipSingleWeapon(rec, placeQuietly)

  local playerPedId = PlayerPedId()
  local WeaponHash  = joaat(rec.hash)

  local model = GetWeapontypeModel(WeaponHash)
  RequestModel(model)
  local modelWait = 0
  while not HasModelLoaded(model) and modelWait < 5000 do
    Wait(50)
    modelWait = modelWait + 50
  end
  if not HasModelLoaded(model) then
    print("weapon model did not load: " .. tostring(rec.hash))
    return false
  end

  if rec.group == 'SHORTARM' then

    if not ItemdatabaseIsKeyValid(WeaponHash, 0) then
      print("Weapon not valid")
      return false
    end

    local slot = (#RegisteredShortarms() >= 1) and 1 or 0
    local characterItem = getGuidFromItemId(1, nil, joaat("CHARACTER"), 0xA1212100)
    local weaponItem = characterItem and getGuidFromItemId(1, characterItem:Buffer(), 923904168, -740156546)
    if not weaponItem then
      print("sem armas")
      return false
    end

    local itemData = DataView.ArrayBuffer(8 * 13)
    if not InventoryAddItemWithGuid(1, itemData:Buffer(), weaponItem:Buffer(), WeaponHash, joaat('SLOTID_WEAPON_' .. tostring(slot)), 1, ADD_REASON_DEFAULT) then
      print("Not added")
      return false
    end
    if not InventoryEquipItemWithGuid(1, itemData:Buffer(), true) then
      print("Unable to equip")
      -- the half-added item must not linger in the slot
      Citizen.InvokeNative(0x3E4E811480B3AE79, 1, itemData:Buffer(), 1, ADD_REASON_DEFAULT)
      return false
    end

    rec.guid = itemData:Buffer()
    rec.slot = slot

    -- the pair goes to the hands together (dual wield when both exist)
    for _, w in ipairs(RegisteredShortarms()) do
      Citizen.InvokeNative(0x12FB95FE3D579238, playerPedId, w.guid, true, w.slot, false, false)
    end

  elseif placeQuietly then

    -- straight to its place on the body, forced into its holster: long
    -- arms on the back, blades in their sheaths, nothing in the hands.
    -- The same call VORP makes when a character logs in.
    GiveWeaponToPed(playerPedId, WeaponHash, rec.ammo or 0, false, true, 0, false, 0.5, 1.0, 0, false, 0.0, false)

  else

    -- the draw below puts away the RIGHT hand only, never the left: an
    -- offhand gun would stay stuck in the left hand under the long gun or
    -- the blade. The left hand is emptied first, the way the game's own
    -- scripts do it (attach point 1 is the offhand).
    SetCurrentPedWeapon(playerPedId, joaat("WEAPON_UNARMED"), true, 1, false, false)

    -- the delayed give plays the real draw-from-back motion, and the engine
    -- holsters the right hand as part of the same motion
    GiveDelayedWeaponToPed(playerPedId, WeaponHash, rec.ammo or 0, true, 0)

  end

  if rec.group ~= 'SHORTARM' then

    -- a slow client can take a while to stream it in (VORP allows 10s)
    local waited = 0
    while not HasPedGotWeapon(playerPedId, WeaponHash, false) and waited < 10000 do
      Wait(50)
      waited = waited + 50
    end
    if not HasPedGotWeapon(playerPedId, WeaponHash, false) then
      print("weapon never reached the ped: " .. tostring(rec.hash))
      RemoveWeaponFromPed(playerPedId, WeaponHash, true, 0)
      return false
    end

  end

  TriggerServerEvent("tpz_inventory:setDefaultUsedWeapons", rec.weaponId)

  -- ammo, dirt and components land on the weapon IN THE HANDS: a weapon
  -- placed straight into its holster is not in them (its ammo is loaded
  -- when it is drawn, by the holding thread below)
  if not placeQuietly or rec.group == 'SHORTARM' then
    ApplyHeldState(rec)
  end
  return true
end

local RefreshBusy, RefreshAgain = false, nil

function RefreshCurrentWeapons(justEquippedId)

  -- one refresh at a time: overlapping runs wipe each other's registrations
  if RefreshBusy then
    RefreshAgain = justEquippedId or RefreshAgain
    return
  end
  RefreshBusy = true

  local playerPedId = PlayerPedId()

  SetCurrentPedWeapon(playerPedId, joaat("WEAPON_UNARMED"), true, 0, false, false)
  Citizen.InvokeNative(0x1B83C0DEEBCBB214, playerPedId)
  RemoveAllPedWeapons(playerPedId, true, true)

  -- deterministic order: pairs() iterates randomly, which shuffled the slot
  -- assignment and the hands between refreshes
  local shortarms, others = {}, {}
  for _, w in pairs(EquippedWeapons) do
    if w.weaponId and w.hash ~= nil then
      if w.group == 'SHORTARM' then
        shortarms[#shortarms + 1] = w
      else
        others[#others + 1] = w
      end
    end
  end
  table.sort(shortarms, function(a, b) return tostring(a.weaponId) < tostring(b.weaponId) end)
  table.sort(others,    function(a, b) return tostring(a.weaponId) < tostring(b.weaponId) end)

  -- SHORTARMS ONLY get the guid slots: SLOTID_WEAPON_0 = right hand,
  -- SLOTID_WEAPON_1 = offhand. Holding is decided once, at the end.
  for i, usedWeapon in ipairs(shortarms) do

    local WeaponHash = joaat(usedWeapon.hash)
    local slot       = (i == 1) and 0 or 1
    local slotHash   = joaat('SLOTID_WEAPON_' .. tostring(slot))

    local model = GetWeapontypeModel(WeaponHash)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local registered = false
    if ItemdatabaseIsKeyValid(WeaponHash, 0) then
      local characterItem = getGuidFromItemId(1, nil, joaat("CHARACTER"), 0xA1212100)
      local weaponItem = characterItem and getGuidFromItemId(1, characterItem:Buffer(), 923904168, -740156546)
      if weaponItem then
        local itemData = DataView.ArrayBuffer(8 * 13)
        if InventoryAddItemWithGuid(1, itemData:Buffer(), weaponItem:Buffer(), WeaponHash, slotHash, 1, ADD_REASON_DEFAULT) then
          if InventoryEquipItemWithGuid(1, itemData:Buffer(), true) then
            -- the held call is what MATERIALIZES the gun on the ped -- skip
            -- it and the weapon never becomes real, so it vanishes from the
            -- weapon wheel. Shortarms run BEFORE the long guns (sorted), so
            -- a rifle drawn later holsters them to the hips naturally.
            Citizen.InvokeNative(0x12FB95FE3D579238, playerPedId, itemData:Buffer(), true, slot, false, false)
            usedWeapon.guid = itemData:Buffer()
            usedWeapon.slot = slot
            registered = true
          end
        end
      end
    end

    -- one failure must not abort the rest of the arsenal
    if registered then
      TriggerServerEvent("tpz_inventory:setDefaultUsedWeapons", usedWeapon.weaponId)
    else
      print("shortarm registration failed: " .. tostring(usedWeapon.hash))
    end
  end

  -- the held call above pins the shortarms to the hands harder than a
  -- normal draw can undo, and SetCurrentPedWeapon(UNARMED) only clears the
  -- RIGHT hand -- the offhand gun stays stuck. _HOLSTER_PED_WEAPONS puts
  -- BOTH hands away (invocation shape straight from the game scripts,
  -- last flag = instantly, no animation).
  if #shortarms > 0 then
    Citizen.InvokeNative(0x94A3C1B804D291EC, playerPedId, false, false, false, false)
    SetCurrentPedWeapon(playerPedId, joaat("WEAPON_UNARMED"), true, 0, false, false)
  end

  -- EVERYTHING ELSE: no slots at all -- the delayed give registers the
  -- weapon on the body without touching the sidearm slots. equipNow must be
  -- TRUE: without it the weapon never fully registers and melee weapons
  -- vanish from the weapon wheel. The hands are settled once, below.
  for _, usedWeapon in ipairs(others) do
    local WeaponHash = joaat(usedWeapon.hash)
    local model = GetWeapontypeModel(WeaponHash)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    GiveDelayedWeaponToPed(playerPedId, WeaponHash, usedWeapon.ammo or 0, true, 0)
    usedWeapon.guid = nil
    usedWeapon.slot = nil
    TriggerServerEvent("tpz_inventory:setDefaultUsedWeapons", usedWeapon.weaponId)
  end

  -- ONE decision about the hands, at the end
  local held = justEquippedId and EquippedWeapons[justEquippedId] or nil

  if held and held.group == 'SHORTARM' then
    for _, w in ipairs(shortarms) do
      if w.guid then
        Citizen.InvokeNative(0x12FB95FE3D579238, playerPedId, w.guid, true, w.slot, false, false)
      end
    end
  elseif held then
    SetCurrentPedWeapon(playerPedId, joaat(held.hash), true, 0, false, false)
  else
    -- nothing should be in the hands: the equip-true gives above drew the
    -- last weapon momentarily, so holster everything -- BOTH hands
    Citizen.InvokeNative(0x94A3C1B804D291EC, playerPedId, false, false, false, false)
    SetCurrentPedWeapon(playerPedId, joaat("WEAPON_UNARMED"), true, 0, false, false)
  end

  -- ammo / dirt / components apply to the weapon actually IN HAND: running
  -- them per weapon while another gun is held lands them on the wrong object
  if held then

    local WeaponHash = joaat(held.hash)

    if held.ammoType then
      Citizen.InvokeNative(0x106A811C6D3035F3, playerPedId, joaat(held.ammoType), held.ammo, 0xCA3454E6)
    else
      SetPedAmmo(playerPedId, WeaponHash, held.ammo)
    end

    local weaponObject = GetCurrentPedWeaponEntityIndex(playerPedId, 0)

    if held.metadata.dirtLevel then
      Citizen.InvokeNative(0x812CE61DEBCAB948, weaponObject, held.metadata.dirtLevel, true)
    end

    if held.metadata.components and TPZ.GetTableLength(held.metadata.components) > 0 then
      RemoveAllWeaponComponents()
      for name, component in pairs(held.metadata.components) do
        if model_specific_components[held.hash] and model_specific_components[held.hash][name] then
          local model = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(component))
          if model then LoadModel(model) end
          Citizen.InvokeNative(0x74C9090FDD1BB48E, playerPedId, joaat(component), WeaponHash, true)
        end
      end
      local weaponType = GetWeaponType(WeaponHash)
      for name, component in pairs(held.metadata.components) do
        if shared_components[weaponType] and shared_components[weaponType][name] then
          local model = Citizen.InvokeNative(0x59DE03442B6C9598, joaat(component))
          if model then LoadModel(model) end
          apply_weapon_component(component)
        end
      end
    end

  end

  RefreshBusy = false
  if RefreshAgain ~= nil then
    local nxt = RefreshAgain
    RefreshAgain = nil
    RefreshCurrentWeapons(nxt)
  end
end

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

AddEventHandler("tpz_weapons:client:run_weapon_tasks", function()

end)

-- WATCH: a new ped has none of the list's weapons. Once it has stayed the
-- same for a second (a skin reload swaps it twice), the list is put back
-- on it, in its own thread so the watch never stops watching. Swaps before
-- a character is in the world (the selection screen) are only noted. A
-- death is never acted on here: it settles through the respawn events
-- above. A ped alive for 15s straight closes a death window that no event
-- closed.
CreateThread(function()

  local lastPed    = PlayerPedId()
  local aliveSince = 0

  while true do
    Wait(500)

    local ped = PlayerPedId()

    if IsEntityDead(ped) then
      DeathWindow = true
      aliveSince  = 0
    elseif DeathWindow then
      if aliveSince == 0 then aliveSince = GetGameTimer() end
      if GetGameTimer() - aliveSince > 15000 then
        DeathWindow = false
      end
    end

    if not DeathWindow and ped ~= lastPed then
      Wait(1000)
      if PlayerPedId() == ped and not DeathWindow then
        lastPed = ped
        if SessionReady then
          CreateThread(RebuildArsenal)
        end
      end
    end
  end
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
