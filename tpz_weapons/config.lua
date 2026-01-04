Config = {}

Config.DevMode = false
Config.Debug   = false

Config.PromptKeys = {
	['OPEN_STORE']    = { label = 'Catalog',         key = 0x760A9C6F, hold = 1000 }, -- G

	['PREVIOUS_ITEM'] = { label = 'Previous Item',   key = 0xA65EBAB4, hold = 250}, -- <
	['NEXT_ITEM']     = { label = 'Next Item',       key = 0xDEB34313, hold = 250}, -- >
	['BUY']           = { label = 'Buy',             key = 0xC7B5340A, hold = 1200 }, -- ENTER

	['CATEGORY']      = { label = 'Change Category', key = 0xD9D0E1C0, hold = 1000 }, -- SPACEBAR
	['EXIT']          = { label = 'Leave',           key = 0x156F7119, hold = 1000 }, -- BACKSPACE
}

-----------------------------------------------------------
--[[ General Settings ]]--
-----------------------------------------------------------

-- NPC Rendering Distance which is deleting the npc when being away from the store location.
Config.NPCRenderingDistance = 30.0

-----------------------------------------------------------
--[[ Cartridge Box Items  ]]--
-----------------------------------------------------------

-- The items below, are boxes to unpack for giving you weapon ammunition.
Config.CartidgeBoxItems = {

	['revolvercartidgebox'] = {
		Item = 'ammorevolvernormal', 
		AmmoQuantity = 60, 
		ProgressTextDisplay = "Unpacking revolver cartidge box..",
		Notify = 'You have received ~o~60 Revolver Ammo Normal.',
	},

	['repeatercartidgebox'] = { 
		Item = 'ammorepeaternormal', 
		AmmoQuantity = 60, 
		ProgressTextDisplay = "Unpacking repeater cartidge box..",
		Notify = 'You have received ~o~60 Repeater Ammo Normal.',
	},

	['pistolcartidgebox'] = { 
		Item = 'ammopistolnormal',   
		AmmoQuantity = 30, 
		ProgressTextDisplay = "Unpacking pistol cartidge box..",
		Notify = 'You have received ~o~30 Pistol Ammo Normal.',
	},

	['varmintcartidgebox'] = { 
		Item = 'ammovarmint',        
		AmmoQuantity = 60, 
		ProgressTextDisplay = "Unpacking varmint cartidge box..",
		Notify = 'You have received ~o~60 Varmint Ammo Normal.',
	},

	['riflecartidgebox'] = { 
		Item = 'ammoriflenormal',    
		AmmoQuantity = 30, 
		ProgressTextDisplay = "Unpacking rifle cartidge box..",
		Notify = 'You have received ~o~30 Rifle Ammo Normal.',
	},
	
	['shotguncartidgebox'] = { 
		Item = 'ammoshotgunnormal',  
		AmmoQuantity = 18, 
		ProgressTextDisplay = "Unpacking shotgun cartidge box..",
		Notify = 'You have received ~o~18 Shotgun Ammo Normal.',
	},
}

-----------------------------------------------------------
--[[ Store Locations ]]--
-----------------------------------------------------------

Config.Stores = {

	['VALENTINE'] = { -- -276.27508544921875, 779.1287841796875, 119.6492919921875

		MenuTitle = 'Gunsmith',

		-- Store location coords.
		Coords = { x = -281.879, y = 780.7117, z = 119.52, h = 181.48803710938 }, 

		-- The weapon or item objects position for displaying properly when purchasing.
		ItemObjectPosition = {x = -281.42352294921875, y = 779.7827758789062, z = 119.633041748047, pitch = 0, roll = 0, yaw = 0},

		BlipData = { -- We are have it disabled because we are displaying the Blip directly from tpz_society.
		    Enabled = true,
			Coords  = { x = -281.767822265625, y = 778.7244873046875, z = 118.50273895263672 },
			Title   = 'Weapons & Ammunition Store',
		    Sprite  = 202506373,
	    },

		-- By enabling the NPC, there will be some extra animations based on it while being on the store.
		NPCData = {
            Enabled = true,
            Model = "u_m_m_valgunsmith_01",
            Coords = {x = -281.767822265625, y = 778.7244873046875, z = 118.50273895263672, h = 10.372212409973},
			Scenario = { Enabled = true, HashName = "WORLD_HUMAN_SHOPKEEPER_MALE_B" },
		},

		-- Set @Enabled to false if you dont want a job to receive money from the specified store on the society ledger.
		SocietyMoney = {
			Enabled  = false,
			Job      = "",
		},

		-- Camera location for displaying the @ItemObjectPosition
		MainCamera = { x = -280.794, y = 780.7434, z = 120.72, rotx = -45.0, roty = 0.0, rotz = 160.0, fov = 36.0},

		-- Set to false if you want the gunsmith store to always be active in any game hours.
		Hours = { Enabled = true, Duration = {am = 7, pm = 21} },

		-- Set to false if you don't want when purchasing a weapon to add a serial number with the bought store location. 
		WeaponSerialNumbers = true,
		WeaponSerialNumberFirstText = 'val',

		ActionDistance = 1.2,

		-- @StoreProductsType displaying all the available weapons and items that can be sold through config_store_products.lua
		-- DEFAULT is the example that has been made in the mentioned file.
		-- You can create your own types for having different weapons, items or even prices.
		StoreProductsType = 'VALENTINE',
	},

	['RHODES'] = {

		MenuTitle = 'Gunsmith',

		-- Store location coords.
		Coords = { x = 1322.834, y = -1321.47, z = 77.889, h = 176.0556335}, 

		-- The weapon or item objects position for displaying properly when purchasing.
		ItemObjectPosition = {x = 1322.2265625, y = -1322.1790771484375, z = 77.94772888183594, pitch = 0, roll = 0, yaw = 0},

		BlipData = { -- We are have it disabled because we are displaying the Blip directly from tpz_society.
		    Enabled = true,
			Coords  = { x = 1322.122, y = -1323.03, z = 77.887 },
			Title   = 'Weapons & Ammunition Store',
		    Sprite  = 202506373,

	    },

		-- By enabling the NPC, there will be some extra animations based on it while being on the store.
		NPCData = {
            Enabled = true,
            Model = "u_m_m_rhdgunsmith_01",
            Coords = {x = 1322.122, y = -1323.03, z = 76.887, h = 359.3123},
			Scenario = { Enabled = true, HashName = "WORLD_HUMAN_SHOPKEEPER_MALE_B" },
		},

		-- Set @Enabled to false if you dont want a job to receive money from the specified store on the society ledger.
		SocietyMoney = {
			Enabled  = false,
			Job      = "",
		},
		
		-- Camera location for displaying the @ItemObjectPosition
		MainCamera = { x = 1322.83, y = -1321.663, z = 78.820, rotx = -55.0, roty = 0.0, rotz = 130.0, fov = 26.0},

		-- Set to false if you want the gunsmith store to always be active in any game hours.
		Hours = { Enabled = true, Duration = {am = 7, pm = 21} },

		-- Set to false if you don't want when purchasing a weapon to add a serial number with the bought store location. 
		WeaponSerialNumbers = true, 
		WeaponSerialNumberFirstText = 'rh',

		ActionDistance = 1.2,

		-- @StoreProductsType displaying all the available weapons and items that can be sold through config_store_products.lua
		-- DEFAULT is the example that has been made in the mentioned file.
		-- You can create your own types for having different weapons, items or even prices.
		StoreProductsType = 'RHODES',
	},

	['SAINTDENIS'] = {

		MenuTitle = 'Gunsmith',

		-- Store location coords.
		Coords = { x = 2715.731, y = -1285.29, z = 49.630, h = 207.649}, 

		-- The weapon or item objects position for displaying properly when purchasing.
		ItemObjectPosition = {x = 2716.442626953125, y = -1286.3338623046875, z = 49.7001528930664, pitch = 0, roll = 0, yaw = 0},

		BlipData = { -- We are have it disabled because we are displaying the Blip directly from tpz_society.
		    Enabled = true,
			Coords  = {x = 2715.731, y = -1285.29, z = 49.630 },
			Title   = 'Weapons & Ammunition Store',
		    Sprite  = 202506373,

	    },

		-- By enabling the NPC, there will be some extra animations based on it while being on the store.
		NPCData = {
            Enabled = true,
            Model = "u_m_m_nbxgunsmith_01",
            Coords = {x = 2716.40478515625, y = -1287.308349609375, z = 48.630, h = 28.21118},
			Scenario = { Enabled = true, HashName = "WORLD_HUMAN_SHOPKEEPER_MALE_B" },
		},

		-- Set @Enabled to false if you dont want a job to receive money from the specified store on the society ledger.
		SocietyMoney = {
			Enabled  = false,
			Job      = "",
		},
		
		-- Camera location for displaying the @ItemObjectPosition
		MainCamera = { x = 2716.498, y = -1285.30, z = 50.830, rotx = -55.0, roty = 5.0, rotz = 180.0, fov = 26.0},

		-- Set to false if you want the gunsmith store to always be active in any game hours.
		Hours = { Enabled = true, Duration = {am = 7, pm = 21} },

		-- Set to false if you don't want when purchasing a weapon to add a serial number with the bought store location. 
		WeaponSerialNumbers = true, 
		WeaponSerialNumberFirstText = 'rh',

		ActionDistance = 1.0,

		-- @StoreProductsType displaying all the available weapons and items that can be sold through config_store_products.lua
		-- DEFAULT is the example that has been made in the mentioned file.
		-- You can create your own types for having different weapons, items or even prices.
		StoreProductsType = 'RHODES',
	},

	['ANNESBURG'] = {

		MenuTitle = 'Gunsmith',

		-- Store location coords.
		Coords = { x = 2946.567, y = 1319.991, z = 44.820, h = 257.772430419 }, 

		-- The weapon or item objects position for displaying properly when purchasing.
		ItemObjectPosition = {x = 2947.330322265625, y = 1319.6854248046875, z = 44.98997985839844, pitch = 0, roll = 0, yaw = 0},

		BlipData = { -- We are have it disabled because we are displaying the Blip directly from tpz_society.
		    Enabled = true,
			Coords  = { x = 2948.311279296875, y = 1319.1077880859375, z = 43.82009506225586 },
			Title   = 'Weapons & Ammunition Store',
		    Sprite  = 202506373,

	    },

		-- By enabling the NPC, there will be some extra animations based on it while being on the store.
		NPCData = {
            Enabled = true,
            Model = "u_m_m_asbgunsmith_01",
            Coords = {x = 2948.311279296875, y = 1319.1077880859375, z = 43.82009506225586, h = 73.46865},
			Scenario = { Enabled = true, HashName = "WORLD_HUMAN_SHOPKEEPER_MALE_B" },
		},

		-- Set @Enabled to false if you dont want a job to receive money from the specified store on the society ledger.
		SocietyMoney = {
			Enabled  = false,
			Job      = "",
		},
		
		-- Camera location for displaying the @ItemObjectPosition
		MainCamera = { x = 2946.813, y = 1320.663, z = 45.820, rotx = -45.0, roty = 0.0, rotz = 220.0, fov = 46.0},

		-- Set to false if you want the gunsmith store to always be active in any game hours.
		Hours = { Enabled = true, Duration = {am = 7, pm = 21} },

		-- Set to false if you don't want when purchasing a weapon to add a serial number with the bought store location. 
		WeaponSerialNumbers = true, 
		WeaponSerialNumberFirstText = 'anes',

		ActionDistance = 1.2,

		-- @StoreProductsType displaying all the available weapons and items that can be sold through config_store_products.lua
		-- DEFAULT is the example that has been made in the mentioned file.
		-- You can create your own types for having different weapons, items or even prices.
		StoreProductsType = 'ANNESBURG',
	},
}

---------------------------------------------------------------
--[[ Webhooks ]]--
---------------------------------------------------------------

-- (!) Checkout tpz_core/server/discord/webhooks.lua to modify the webhook urls.
Config.Webhooks = {
    
    ['DEVTOOLS_INJECTION_CHEAT'] = { -- Warnings and Logs about players who used or atleast tried to use devtools injection.
        Enabled = false, 
        Color = 10038562,
    },

}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source is always null when called from client.
-- @type returns "success" or "error" based on actions.
function SendNotification(source, message, type)
    local duration = 3000

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, duration)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, duration)
    end


end

