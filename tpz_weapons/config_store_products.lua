
-----------------------------------------------------------
--[[ Store Product Types ]]--
-----------------------------------------------------------

-- (!) ALL WEAPONS ARE BOUGHT ONLY AS X1 QUANTITY AUTOMATICALLY BY THE SYSTEM.
-- Only ammunition have TPZ Inputs available to select the quantity when purchasing.

Config.Types = {

	['VALENTINE'] = {

		['WEAPONS'] = { -- (!) DO NOT REMOVE, IF NO ITEMS, SET Items = {}

			Label = 'Weapons',

			Items = {

				{
		
					Label       = 'Hunting Knife',
					Description = 'An all-purpose Bowie knife with a sharp clip-point blade, steel crossguard, and sturdy wooden handle. Designed for combat, this weapon can give the edge to any close-quarters melee fight, or be used for silent takedowns. For hunters, this is also the perfect weapon for killing and skinning animals.',
					HashName    = 'WEAPON_MELEE_KNIFE',
	
					Cost        = 7,

					PriceUIDisplay = 0700, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_KNIFE',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = -37.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.075,

					SetCamFov = 35.0,
				},
	

				{
		
					Label       = 'Cattleman Revolver',
					Description = 'A popular and classic sidearm, the Buck Cattleman is a great all-around revolver, featuring a good balance of damage, accuracy and fire rate. Suited for close to medium-range combat, this gun can also be dual-wielded and used on horseback.',
					HashName    = 'WEAPON_REVOLVER_CATTLEMAN',
	
					Cost        = 50,

					PriceUIDisplay = 5000, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_REVOLVER_CATTLEMAN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.06,
					
					SetCamFov = 25.0,
				},

				{
		
					Label       = 'Varmint Rifle',
					Description = 'The quick-firing Lancaster Varmint Rifle is designed for hunting small mammals and large birds, using a special low-caliber type of ammunition with reduced damage.',
					HashName    = 'WEAPON_RIFLE_VARMINT',
	
					Cost        = 72,

					PriceUIDisplay = 7200, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_RIFLE_VARMINT',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly
					DecreasePlacementHeightBy = 0.07,

					SetCamFov = 46.0,
				},

				{
					Label       = 'Throwing Knives',
					Description = 'A small knife with a straight blade, designed and balanced so it can be thrown with ease. Can be used to silently take down enemies at range, or used as a melee weapon if required.',
					HashName    = 'p_knivesbundle02x',
	
					Cost        = 0.75,

					PriceUIDisplay = 0075, -- This is for the UI, to display the price properly.

					Item = "WEAPON_THROWN_THROWING_KNIVES",
					
					-- Knives are always X1.
					RequestInputQuantity = false, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

			},
			
		},

		['AMMUNITION'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
			Label = 'Ammunition',

			Items = {

				{ 
					Label       = 'Revolver Ammo Normal',
					Description = 'Performance. Reliability. Accuracy. These cartridges have the required effect intended and will cause interlopers to have certain changes in their behaviour.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_revolverammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "revolvercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = true,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 25.0,

				},

				{ 
					Label       = 'Repeater Ammo Normal',
					Description = 'A favorite pastime of young boys is shooting tin cans across a field, using these cartridges, enjoying the last days of summer before the long dark winter culls sickly members of the family.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_repeater_revammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "repeatercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 25.0,
				},
				
				{ 
					Label       = 'Pistol Ammo Normal',
					Description = 'The dependable choice. The reason that life is, to so many, a dismal failure is because they do not have the prudence and forethought to order a great many boxes of these cartridges.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_pistolammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.
	
					Item = "pistolcartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,
	
					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},
	
					SetCamFov = 25.0,
				},

				{ 
					Label       = 'Varmint Ammo',
					Description = 'Lancaster Rifle .22 Caliber Varmint Cartridges designed for hunting small game with sure fire performance and accuracy.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_varmint_rifleammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "varmintcartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 25.0,
				},
	
				{
					Label       = 'Rifle Ammo Normal',
					Description = 'As the crack of your rifle ricochets off the walls of the canyon, and the man lies dead in the distance, the birds go silent in the noonday sun, and yet again King Load never failed you.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_rifleammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "riflecartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 25.0,
				},

				{
					Label       = 'Shotgun Shells Normal',
					Description = 'The traditional reliable choice. For those encounter the pusillanimous lot out there that would take a mans horse, these are sure to put a finale on their caper, guaranteed.\n\nEach box contains 18 shells.',
					HashName    = 'mp005_s_hl_cmb_tortshell',
	
					Cost        = 1,

					PriceUIDisplay   = 0100, -- This is for the UI, to display the price properly.

					Item = "shotguncartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 25.0,
				},

	
				{
					Label       = 'Small Game Arrow',
					Description = 'Small Game Arrows do reduced damage only, mostly for injures, you might want to use them only for small animals, such as squirrels, rats and other tiny animals.\n\nX1 Quantity.',
					HashName    = 's_cft_arrow_smallgame',
	
					Cost        = 0.10,

					PriceUIDisplay = 0010, -- This is for the UI, to display the price properly.

					Item = "ammoarrowsmallgame",

					-- Bows are always X1, weapon ammunition have boxes.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)
					
					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = -37.0,
					},

					SetCamFov = 35.0,
				},

			},

		},

		['MISC'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
	
			Label = 'Miscellaneous',
			
			Items = { 

				{
	
					Label       = 'Binoculars',
					Description = 'Binoculars, optical instrument, usually handheld, for providing a magnified stereoscopic view of distant objects. It consists of two similar telescopes, one for each eye, mounted on a single frame.',
					HashName    = 'WEAPON_KIT_BINOCULARS',
	
					Cost        = 28,

					PriceUIDisplay = 2800, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_KIT_BINOCULARS',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 30.0,
				},
	
				{
	
					Label       = 'Lantern',
					Description = 'The lantern can be used for light during the night or trailing through dark places.',
					HashName    = 'WEAPON_MELEE_LANTERN',
	
					Cost        = 5,

					PriceUIDisplay = 0500, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_LANTERN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 40.0,
				},


			},
			
		},
		
	},

	['RHODES'] = {

		['WEAPONS'] = { -- (!) DO NOT REMOVE, IF NO ITEMS, SET Items = {}

			Label = 'Weapons',

			Items = {

				{
		
					Label       = 'Hunting Knife',
					Description = 'An all-purpose Bowie knife with a sharp clip-point blade, steel crossguard, and sturdy wooden handle. Designed for combat, this weapon can give the edge to any close-quarters melee fight, or be used for silent takedowns. For hunters, this is also the perfect weapon for killing and skinning animals.',
					HashName    = 'WEAPON_MELEE_KNIFE',
	
					Cost        = 7,

					PriceUIDisplay = 0700, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_KNIFE',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 87.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.015,

					SetCamFov = 35.0,
				},
	

				{
		
					Label       = 'Cattleman Revolver',
					Description = 'A popular and classic sidearm, the Buck Cattleman is a great all-around revolver, featuring a good balance of damage, accuracy and fire rate. Suited for close to medium-range combat, this gun can also be dual-wielded and used on horseback.',
					HashName    = 'WEAPON_REVOLVER_CATTLEMAN',
	
					Cost        = 50,

					PriceUIDisplay = 5000, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_REVOLVER_CATTLEMAN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,
					
					SetCamFov = 40.0,
				},

				{
		
					Label       = 'Varmint Rifle',
					Description = 'The quick-firing Lancaster Varmint Rifle is designed for hunting small mammals and large birds, using a special low-caliber type of ammunition with reduced damage.',
					HashName    = 'WEAPON_RIFLE_VARMINT',
	
					Cost        = 72,

					PriceUIDisplay = 7200, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_RIFLE_VARMINT',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 50.0,
				},

				{
					Label       = 'Throwing Knives',
					Description = 'A small knife with a straight blade, designed and balanced so it can be thrown with ease. Can be used to silently take down enemies at range, or used as a melee weapon if required.',
					HashName    = 'p_knivesbundle02x',
	
					Cost        = 0.75,

					PriceUIDisplay = 0075, -- This is for the UI, to display the price properly.

					Item = "WEAPON_THROWN_THROWING_KNIVES",
					
					-- Knives are always X1.
					RequestInputQuantity = false, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

			},
			
		},

		['AMMUNITION'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
			Label = 'Ammunition',

			Items = {

				{ 
					Label       = 'Revolver Ammo Normal',
					Description = 'Performance. Reliability. Accuracy. These cartridges have the required effect intended and will cause interlopers to have certain changes in their behaviour.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_revolverammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "revolvercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = true,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

				{ 
					Label       = 'Repeater Ammo Normal',
					Description = 'A favorite pastime of young boys is shooting tin cans across a field, using these cartridges, enjoying the last days of summer before the long dark winter culls sickly members of the family.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_repeater_revammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "repeatercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},
				
				{ 
					Label       = 'Pistol Ammo Normal',
					Description = 'The dependable choice. The reason that life is, to so many, a dismal failure is because they do not have the prudence and forethought to order a great many boxes of these cartridges.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_pistolammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.
	
					Item = "pistolcartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,
	
					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},
	
					SetCamFov = 30.0,
				},

				{ 
					Label       = 'Varmint Ammo',
					Description = 'Lancaster Rifle .22 Caliber Varmint Cartridges designed for hunting small game with sure fire performance and accuracy.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_varmint_rifleammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "varmintcartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},
	
				{
					Label       = 'Rifle Ammo Normal',
					Description = 'As the crack of your rifle ricochets off the walls of the canyon, and the man lies dead in the distance, the birds go silent in the noonday sun, and yet again King Load never failed you.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_rifleammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "riflecartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},

				{
					Label       = 'Shotgun Shells Normal',
					Description = 'The traditional reliable choice. For those encounter the pusillanimous lot out there that would take a mans horse, these are sure to put a finale on their caper, guaranteed.\n\nEach box contains 18 shells.',
					HashName    = 'mp005_s_hl_cmb_tortshell',
	
					Cost        = 1,

					PriceUIDisplay   = 0100, -- This is for the UI, to display the price properly.

					Item = "shotguncartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},

	
				{
					Label       = 'Small Game Arrow',
					Description = 'Small Game Arrows do reduced damage only, mostly for injures, you might want to use them only for small animals, such as squirrels, rats and other tiny animals.\n\nX1 Quantity.',
					HashName    = 's_cft_arrow_smallgame',
	
					Cost        = 0.10,

					PriceUIDisplay = 0010, -- This is for the UI, to display the price properly.

					Item = "ammoarrowsmallgame",

					-- Bows are always X1, weapon ammunition have boxes.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)
					
					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = -87.0,
					},

					SetCamFov = 40.0,
				},

			},

		},

		['MISC'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
	
			Label = 'Miscellaneous',
			
			Items = { 

				{
	
					Label       = 'Binoculars',
					Description = 'Binoculars, optical instrument, usually handheld, for providing a magnified stereoscopic view of distant objects. It consists of two similar telescopes, one for each eye, mounted on a single frame.',
					HashName    = 'WEAPON_KIT_BINOCULARS',
	
					Cost        = 28,

					PriceUIDisplay = 2800, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_KIT_BINOCULARS',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 90.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 35.0,
				},
	
				{
	
					Label       = 'Lantern',
					Description = 'The lantern can be used for light during the night or trailing through dark places.',
					HashName    = 'WEAPON_MELEE_LANTERN',
	
					Cost        = 5,

					PriceUIDisplay = 0500, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_LANTERN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 45.0,
				},


			},
			
		},
		
	},

	['SAINTDENIS'] = {

		['WEAPONS'] = { -- (!) DO NOT REMOVE, IF NO ITEMS, SET Items = {}

			Label = 'Weapons',

			Items = {

				{
		
					Label       = 'Hunting Knife',
					Description = 'An all-purpose Bowie knife with a sharp clip-point blade, steel crossguard, and sturdy wooden handle. Designed for combat, this weapon can give the edge to any close-quarters melee fight, or be used for silent takedowns. For hunters, this is also the perfect weapon for killing and skinning animals.',
					HashName    = 'WEAPON_MELEE_KNIFE',
	
					Cost        = 7,

					PriceUIDisplay = 0700, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_KNIFE',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 87.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.015,

					SetCamFov = 35.0,
				},
	

				{
		
					Label       = 'Cattleman Revolver',
					Description = 'A popular and classic sidearm, the Buck Cattleman is a great all-around revolver, featuring a good balance of damage, accuracy and fire rate. Suited for close to medium-range combat, this gun can also be dual-wielded and used on horseback.',
					HashName    = 'WEAPON_REVOLVER_CATTLEMAN',
	
					Cost        = 50,

					PriceUIDisplay = 5000, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_REVOLVER_CATTLEMAN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,
					
					SetCamFov = 40.0,
				},

				{
		
					Label       = 'Varmint Rifle',
					Description = 'The quick-firing Lancaster Varmint Rifle is designed for hunting small mammals and large birds, using a special low-caliber type of ammunition with reduced damage.',
					HashName    = 'WEAPON_RIFLE_VARMINT',
	
					Cost        = 72,

					PriceUIDisplay = 7200, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_RIFLE_VARMINT',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 50.0,
				},

				{
					Label       = 'Throwing Knives',
					Description = 'A small knife with a straight blade, designed and balanced so it can be thrown with ease. Can be used to silently take down enemies at range, or used as a melee weapon if required.',
					HashName    = 'p_knivesbundle02x',
	
					Cost        = 0.75,

					PriceUIDisplay = 0075, -- This is for the UI, to display the price properly.

					Item = "WEAPON_THROWN_THROWING_KNIVES",
					
					-- Knives are always X1.
					RequestInputQuantity = false, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

			},
			
		},

		['AMMUNITION'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
			Label = 'Ammunition',

			Items = {

				{ 
					Label       = 'Revolver Ammo Normal',
					Description = 'Performance. Reliability. Accuracy. These cartridges have the required effect intended and will cause interlopers to have certain changes in their behaviour.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_revolverammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "revolvercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = true,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

				{ 
					Label       = 'Repeater Ammo Normal',
					Description = 'A favorite pastime of young boys is shooting tin cans across a field, using these cartridges, enjoying the last days of summer before the long dark winter culls sickly members of the family.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_repeater_revammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "repeatercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},
				
				{ 
					Label       = 'Pistol Ammo Normal',
					Description = 'The dependable choice. The reason that life is, to so many, a dismal failure is because they do not have the prudence and forethought to order a great many boxes of these cartridges.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_pistolammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.
	
					Item = "pistolcartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,
	
					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},
	
					SetCamFov = 30.0,
				},

				{ 
					Label       = 'Varmint Ammo',
					Description = 'Lancaster Rifle .22 Caliber Varmint Cartridges designed for hunting small game with sure fire performance and accuracy.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_varmint_rifleammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "varmintcartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},
	
				{
					Label       = 'Rifle Ammo Normal',
					Description = 'As the crack of your rifle ricochets off the walls of the canyon, and the man lies dead in the distance, the birds go silent in the noonday sun, and yet again King Load never failed you.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_rifleammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "riflecartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},

				{
					Label       = 'Shotgun Shells Normal',
					Description = 'The traditional reliable choice. For those encounter the pusillanimous lot out there that would take a mans horse, these are sure to put a finale on their caper, guaranteed.\n\nEach box contains 18 shells.',
					HashName    = 'mp005_s_hl_cmb_tortshell',
	
					Cost        = 1,

					PriceUIDisplay   = 0100, -- This is for the UI, to display the price properly.

					Item = "shotguncartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},

	
				{
					Label       = 'Small Game Arrow',
					Description = 'Small Game Arrows do reduced damage only, mostly for injures, you might want to use them only for small animals, such as squirrels, rats and other tiny animals.\n\nX1 Quantity.',
					HashName    = 's_cft_arrow_smallgame',
	
					Cost        = 0.10,

					PriceUIDisplay = 0010, -- This is for the UI, to display the price properly.

					Item = "ammoarrowsmallgame",

					-- Bows are always X1, weapon ammunition have boxes.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)
					
					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = -87.0,
					},

					SetCamFov = 40.0,
				},

			},

		},

		['MISC'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
	
			Label = 'Miscellaneous',
			
			Items = { 

				{
	
					Label       = 'Binoculars',
					Description = 'Binoculars, optical instrument, usually handheld, for providing a magnified stereoscopic view of distant objects. It consists of two similar telescopes, one for each eye, mounted on a single frame.',
					HashName    = 'WEAPON_KIT_BINOCULARS',
	
					Cost        = 28,

					PriceUIDisplay = 2800, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_KIT_BINOCULARS',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 90.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 35.0,
				},
	
				{
	
					Label       = 'Lantern',
					Description = 'The lantern can be used for light during the night or trailing through dark places.',
					HashName    = 'WEAPON_MELEE_LANTERN',
	
					Cost        = 5,

					PriceUIDisplay = 0500, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_LANTERN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.0,

					SetCamFov = 45.0,
				},


			},
			
		},
		
	},

	['ANNESBURG'] = {

		['WEAPONS'] = { -- (!) DO NOT REMOVE, IF NO ITEMS, SET Items = {}

			Label = 'Weapons',

			Items = {

				{
		
					Label       = 'Hunting Knife',
					Description = 'An all-purpose Bowie knife with a sharp clip-point blade, steel crossguard, and sturdy wooden handle. Designed for combat, this weapon can give the edge to any close-quarters melee fight, or be used for silent takedowns. For hunters, this is also the perfect weapon for killing and skinning animals.',
					HashName    = 'WEAPON_MELEE_KNIFE',
	
					Cost        = 7,

					PriceUIDisplay = 0700, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_KNIFE',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 70.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.11,

					SetCamFov = 40.0,
				},
	

				{
		
					Label       = 'Cattleman Revolver',
					Description = 'A popular and classic sidearm, the Buck Cattleman is a great all-around revolver, featuring a good balance of damage, accuracy and fire rate. Suited for close to medium-range combat, this gun can also be dual-wielded and used on horseback.',
					HashName    = 'WEAPON_REVOLVER_CATTLEMAN',
	
					Cost        = 50,

					PriceUIDisplay = 5000, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_REVOLVER_CATTLEMAN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 40.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.10,
					
					SetCamFov = 30.0,
				},

				{
		
					Label       = 'Varmint Rifle',
					Description = 'The quick-firing Lancaster Varmint Rifle is designed for hunting small mammals and large birds, using a special low-caliber type of ammunition with reduced damage.',
					HashName    = 'WEAPON_RIFLE_VARMINT',
	
					Cost        = 72,

					PriceUIDisplay = 7200, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_RIFLE_VARMINT',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 40.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.109,

					SetCamFov = 46.0,
				},

				{
					Label       = 'Throwing Knives',
					Description = 'A small knife with a straight blade, designed and balanced so it can be thrown with ease. Can be used to silently take down enemies at range, or used as a melee weapon if required.',
					HashName    = 'p_knivesbundle02x',
	
					Cost        = 0.75,

					PriceUIDisplay = 0075, -- This is for the UI, to display the price properly.

					Item = "WEAPON_THROWN_THROWING_KNIVES",
					
					-- Knives are always X1.
					RequestInputQuantity = false, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

			},
			
		},

		['AMMUNITION'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
			Label = 'Ammunition',

			Items = {

				{ 
					Label       = 'Revolver Ammo Normal',
					Description = 'Performance. Reliability. Accuracy. These cartridges have the required effect intended and will cause interlopers to have certain changes in their behaviour.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_revolverammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "revolvercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,

				},

				{ 
					Label       = 'Repeater Ammo Normal',
					Description = 'A favorite pastime of young boys is shooting tin cans across a field, using these cartridges, enjoying the last days of summer before the long dark winter culls sickly members of the family.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_repeater_revammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "repeatercartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},
				
				{ 
					Label       = 'Pistol Ammo Normal',
					Description = 'The dependable choice. The reason that life is, to so many, a dismal failure is because they do not have the prudence and forethought to order a great many boxes of these cartridges.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_pistolammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.
	
					Item = "pistolcartidgebox",
					
					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,
	
					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},
	
					SetCamFov = 30.0,
				},

				{ 
					Label       = 'Varmint Ammo',
					Description = 'Lancaster Rifle .22 Caliber Varmint Cartridges designed for hunting small game with sure fire performance and accuracy.\n\nEach box contains 60 cartridges.',
					HashName    = 's_inv_varmint_rifleammo01x',
	
					Cost        = 1,

					PriceUIDisplay = 0100, -- This is for the UI, to display the price properly.

					Item = "varmintcartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},
	
				{
					Label       = 'Rifle Ammo Normal',
					Description = 'As the crack of your rifle ricochets off the walls of the canyon, and the man lies dead in the distance, the birds go silent in the noonday sun, and yet again King Load never failed you.\n\nEach box contains 30 cartridges.',
					HashName    = 's_inv_rifleammo01x',
	
					Cost        = 1.50,

					PriceUIDisplay = 0150, -- This is for the UI, to display the price properly.

					Item = "riflecartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},

				{
					Label       = 'Shotgun Shells Normal',
					Description = 'The traditional reliable choice. For those encounter the pusillanimous lot out there that would take a mans horse, these are sure to put a finale on their caper, guaranteed.\n\nEach box contains 18 shells.',
					HashName    = 'mp005_s_hl_cmb_tortshell',
	
					Cost        = 1,

					PriceUIDisplay   = 0100, -- This is for the UI, to display the price properly.

					Item = "shotguncartidgebox",

					-- Set as false since the purchased box (@Item) when used and it will give the configured ammo from Config.CartidgeBoxItems.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					SetCamFov = 30.0,
				},

	
				{
					Label       = 'Small Game Arrow',
					Description = 'Small Game Arrows do reduced damage only, mostly for injures, you might want to use them only for small animals, such as squirrels, rats and other tiny animals.\n\nX1 Quantity.',
					HashName    = 's_cft_arrow_smallgame',
	
					Cost        = 0.10,

					PriceUIDisplay = 0010, -- This is for the UI, to display the price properly.

					Item = "ammoarrowsmallgame",

					-- Bows are always X1, weapon ammunition have boxes.
					RequestInputQuantity = true, -- Requesting Purchasing Quantity (TPZ_INPUTS)
					
					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 130.0,
					},

					SetCamFov = 40.0,
				},
	
			},

		},

		['MISC'] = { -- (!) (DO NOT REMOVE), IF NO ITEMS, SET Items = {}
	
			Label = 'Miscellaneous',
			
			Items = { 

				{
	
					Label       = 'Binoculars',
					Description = 'Binoculars, optical instrument, usually handheld, for providing a magnified stereoscopic view of distant objects. It consists of two similar telescopes, one for each eye, mounted on a single frame.',
					HashName    = 'WEAPON_KIT_BINOCULARS',
	
					Cost        = 28,

					PriceUIDisplay = 2800, -- This is for the UI, to display the price properly.

					Item = 'WEAPON_KIT_BINOCULARS',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = true,
						Pitch   = 90.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.070,

					SetCamFov = 35.0,
				},
	
				{
	
					Label       = 'Lantern',
					Description = 'The lantern can be used for light during the night or trailing through dark places.',
					HashName    = 'WEAPON_MELEE_LANTERN',
	
					Cost        = 5,

					PriceUIDisplay = 0500, -- This is for the UI, to display the price properly.
					
					Item = 'WEAPON_MELEE_LANTERN',

					-- The specified options below are for discounts only.
					modifiedPriceVisible  = false,
					purchaseModifiedPrice = 0,

					Rotation = {
						Enabled = false,
						Pitch   = 0.0,
						Roll    = 0.0,
						Yaw     = 0.0,
					},

					-- @DecreasePlacementHeightBy is required to place the object properly.
					DecreasePlacementHeightBy = 0.13,

					SetCamFov = 45.0,
				},


			},
			
		},
		
	},
}