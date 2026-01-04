local TPZ    = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_weapons:requestPlayerAccount")
AddEventHandler("tpz_weapons:requestPlayerAccount", function()
  local _source        = source
  local xPlayer        = TPZ.GetPlayer(_source)

  local currentDollars = xPlayer.getAccount(0)

  -- Updating UI (Display Account)
  TriggerClientEvent("tpz_weapons:client:updatePlayerAccount", _source, { currentDollars })

end)

RegisterServerEvent("tpz_weapons:server:buySelectedItem")
AddEventHandler("tpz_weapons:server:buySelectedItem", function(locationIndex, categoryIndex, selectedItemIndex, item, label, quantity)
  local _source    = source
  local xPlayer    = TPZ.GetPlayer(_source)
    
  if xPlayer.hasLostConnection() then 
    print(string.format('A player with the steam name as: %s and online id: %s, attempted to buy an item / weapon from weapons store while his connection is lost.', GetPlayerName(_source), _source))
    return 
  end

  local ItemData   = Config.Types[locationIndex][categoryIndex].Items[selectedItemIndex]
  local IsWeapon   = TPZ.StartsWith(item, 'WEAPON_')

  quantity         = math.floor(quantity)

  if quantity <= 0 then
    SendNotification(_source, Locales['INVALID_QUANTITY'], 'error')
    return
  end

  -- We check if item does not exist, if target item is not the same, if the weapon quantity is not (1) or quantity is invalid.
  -- Devtools 100%
  if (ItemData.Item ~= item) or (IsWeapon and quantity ~= 1) then

    if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
      local _w, _c      = TPZ.GetWebhookUrl('tpz_weapons', 'DEVTOOLS_INJECTION_CHEAT'), Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
      local description = 'The specified user attempted to use devtools / injection or netbug cheat on weapons store.'
      TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
    end
  
    xPlayer.ban(Locales['DEVTOOLS_INJECTION_DETECTED'], -1)
    return
  end

  local totalCost    = tonumber(ItemData.Cost * tonumber(quantity))
  local currentMoney = xPlayer.getAccount(0)

  if currentMoney < totalCost then
    SendNotification(_source, Locales['NOT_ENOUGH_MONEY'], 'error')
    return
  end

  if IsWeapon then

    local canCarryWeapon = TPZInv.canCarryWeapon(_source, item)

    if not canCarryWeapon then
      SendNotification(_source, Locales['NOT_ENOUGH_INVENTORY_WEIGHT'], 'error')
      return
    end

    local hours, minutes, seconds = os.date('%H'), os.date('%M'), os.date('%S')

    local randomSerialNumber = Config.Stores[locationIndex].WeaponSerialNumberFirstText .. "-" .. tonumber(hours) .. tonumber(minutes) .. tonumber(seconds) .. math.random(1, 9).. math.random(1, 9).. math.random(1, 9)
    local serialNumber       = Config.Stores[locationIndex].WeaponSerialNumbers and randomSerialNumber or nil

    TPZInv.addWeapon(_source, item, serialNumber)

    local displayNotification = string.format(Locales['SUCCESSFULLY_BOUGHT_WEAPON'], label, totalCost)
    SendNotification(_source, displayNotification, 'success')
      
    if Config.Stores[locationIndex].SocietyMoney.Enabled then 
      exports.tpz_society:getAPI().updateSocietyLedgerAccount(Config.Stores[locationIndex].SocietyMoney.Job, 'ADD', totalCost)
    end

    xPlayer.removeAccount(0, totalCost)
      
    -- Updating UI (Display Account)
    currentMoney = xPlayer.getAccount(0)
    TriggerClientEvent("tpz_weapons:client:updatePlayerAccount", _source, { currentMoney })

  else

    local canCarryItem = TPZInv.canCarryItem(_source, item, quantity)

    if not canCarryItem then
      SendNotification(_source, Locales['NOT_ENOUGH_INVENTORY_WEIGHT'], 'error')
      return
    end

    TPZInv.addItem(_source, item, quantity)
  
    local displayNotification = string.format(Locales['SUCCESSFULLY_BOUGHT_ITEM'], quantity, label, totalCost)
    SendNotification(_source, displayNotification, 'success')
      
    if Config.Stores[locationIndex].SocietyMoney.Enabled then 
      exports.tpz_society:getAPI().updateSocietyLedgerAccount(Config.Stores[locationIndex].SocietyMoney.Job, 'ADD', totalCost)
    end

    xPlayer.removeAccount(0, totalCost)
      
    -- Updating UI (Display Account)
    currentMoney = xPlayer.getAccount(0)
    TriggerClientEvent("tpz_weapons:client:updatePlayerAccount", _source, { currentMoney })

  end

end) 



