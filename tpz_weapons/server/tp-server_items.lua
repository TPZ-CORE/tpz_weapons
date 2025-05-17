local TPZInv = exports.tpz_inventory:getInventoryAPI()

local CooldownPlayers = {}

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function () 

	if Config.CartidgeBoxItems and #Config.CartidgeBoxItems > 0 then

		for item, v in pairs (Config.CartidgeBoxItems) do

			TPZInv.registerUsableItem(item, GetCurrentResourceName(), function(data)

				local _source = data.source

				if CooldownPlayers[_source] then
					-- on cooldown
					return
				end

				local canCarryItem = TPZInv.canCarryItem(_source, v.Item, v.AmmoQuantity)

				if not canCarryItem then 
					TriggerClientEvent("tpz_core:sendBottomTipNotification", _source, Locales['NOT_ENOUGH_INVENTORY_WEIGHT'], 3000)
					return
				end

				CooldownPlayers[_source] = true

				TriggerClientEvent("tpz_weapons:unpackCartidgeBoxItem", _source, item)

				TPZInv.closeInventory(_source)

				Wait(3000)

				TPZInv.removeItem(_source, item, 1)
				TPZInv.addItem(_source, v.Item, v.AmmoQuantity)

				SendNotification(_source,  v.Notify, 'success')
				CooldownPlayers[_source] = nil
			end)
			
		end

	end

end)