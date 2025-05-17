local TPZ = exports.tpz_core:getCoreAPI()

---@diagnostic disable: undefined-global
MenuData = {}

TriggerEvent("tpz_menu_base:getData", function(call)
    MenuData = call
end)

local WeaponComponents = {}

local IsWeaponComponentModelLoading = false

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetWeaponComponents(weaponHashName)

    for index, components in pairs(model_specific_components) do

        if index == weaponHashName then
            return components, index
        end

    end

    return {} , wepHash
end

local function GetWeaponTypeSharedComponents(weaponType)

    for index, components in pairs(shared_components) do

        if index == weaponType then
            return components, index
        end

    end

    return {} , weaponType
end


local GetComponentIndexByWeaponName = function(weaponType, weaponHashName, type, component)

    local weaponComponentsList = model_specific_components[weaponHashName][type]

    if weaponComponentsList then
        
        for index, types in pairs (weaponComponentsList) do

            if types.item == component then
    
                return index
    
            end
    
        end

    end

    local weaponSharedComponentsList = shared_components[weaponType][type]

    if weaponSharedComponentsList then
        
        for index, types in pairs (weaponSharedComponentsList) do

            if types.item == component then
    
                return index
    
            end
    
        end

    end

end

local function GetWeaponType(hash)

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

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

OpenWeaponComponentsByComponent = function (locationIndex, weaponData, weaponObject, component)

    local elements = {}

   -- for index, val in pairs (model_specific_components[weaponData.hashName][component]) do 
    --    table.insert(elements, { value = val.item, label = val.label, desc = "" })
    --end
    local weaponType            = GetWeaponType(GetHashKey(weaponData.hashName))
    --local foundSharedComponents = GetWeaponTypeSharedComponents(weaponType)

    local minimumIndex = 0

    if component == 'GRIP' or component == 'BARREL' then
        minimumIndex = 1
    end

    if WeaponComponents[component] == nil or WeaponComponents[component].index == nil then
        WeaponComponents[component] = { name = nil, index = minimumIndex }
    end

    if model_specific_components[weaponData.hashName][component] then
        table.insert(elements, { 
            value = WeaponComponents[component].index, 
            label = Locales['MENU_CUSTOMIZATION_' .. component], 
            desc = "",
            type = "slider",
            min = minimumIndex, 
            max = GetTableLength(model_specific_components[weaponData.hashName][component]),
            shared = 0,

            name = component,
        })

    end

    for index, shared_component in pairs(shared_components[weaponType]) do

        if StartsWith(index, component) then

            if WeaponComponents[index] == nil then
                WeaponComponents[index] = { name = nil, index = 0 }
            end

            local args  = Split(index, '_')
            local label = index:gsub(args[1], "")

            if args[2] == nil then
                label = '_' .. index
            end

            table.insert(elements, { 
                value = WeaponComponents[index].index, 
                label = Locales[ 'MENU_CUSTOMIZATION' .. label ], 
                desc = "",
                type = "slider",
                min = 0, 
                max = GetTableLength(shared_components[weaponType][index]),
                shared = 1,

                name = index
            })

            print(index)

        end

    end

    --table.insert(elements, { value = 'n/a', label = ' ', desc = '' })

    --table.insert(elements, { value = 'buy', label = string.format(Locales['MENU_BUY_COMPONENT_BUTTON'], Locales['MENU_CUSTOMIZATION_' .. component]), desc = '' })
   -- table.insert(elements, { value = 'reset', label = string.format(Locales['MENU_RESET_COMPONENT_BUTTON'], Locales['MENU_CUSTOMIZATION_' .. component]), desc = '' })
    table.insert(elements, { value = 'back', label = Locales['MENU_BACK_BUTTON'], desc = '' })

    MenuData.Open('default', GetCurrentResourceName() .. "weapon_components_selected", 'tpz_menu_base',
    {
        title    = Locales['MENU_TITLE'],
        subtext  = Locales['MENU_CUSTOMIZATION_' .. component],
        align    = "left",
        elements = elements,
        lastmenu = "MAIN"
    },

    function(data, menu)
        if (data.current == "backup" or data.current.value == "back") then -- go back
            menu.close()
            OpenWeaponComponentsByWeapon(locationIndex, weaponData, weaponObject)
            return
        end

        if (data.current.value == 'n/a') then
            return
        end

        if IsWeaponComponentModelLoading then
            return
        end

        IsWeaponComponentModelLoading = true
        -- check money 

        -- [ CLEAR / REMOVE COMPONENTS FROM WEAPON OBJECT BEFORE UPDATING]
        local componentList = nil
        local componentName = nil

        local componentType = data.current.name

        if data.current.shared == 0 then
            componentList = model_specific_components[weaponData.hashName][componentType]

            componentName = nil

            if model_specific_components[weaponData.hashName][componentType][data.current.value] then
                componentName = model_specific_components[weaponData.hashName][componentType][data.current.value].item
            else 
                TriggerServerEvent("tpz_inventory:setWeaponMetadata", weaponData.value, 'COMPONENT', { componentType, 0 } )
                WeaponComponents[componentType] = { name = nil, index = 0 }

            end
        
        else
            
            componentList = shared_components[weaponType][componentType]

            componentName = nil
            
            if shared_components[weaponType][componentType][data.current.value] then
                componentName = shared_components[weaponType][componentType][data.current.value].item
            else
                TriggerServerEvent("tpz_inventory:setWeaponMetadata", weaponData.value, 'COMPONENT', { componentType, 0 } )
                WeaponComponents[componentType] = { name = nil, index = 0 }

            end

        end

        -- We reset first the specified component type from the weapon to avoid bugs
        -- If not using the following part, it will display different textures or not correct ones.
        for k,v in pairs(componentList) do
            --print(v.item)
            RemoveWeaponComponentFromWeaponObject(weaponObject, GetHashKey(v.item))
        end

        if componentName then

            if componentType ~= 'WRAP_TINT' then
                local model = Citizen.InvokeNative(0x59DE03442B6C9598, GetHashKey(componentName) )
    
                if model then
                    LoadModel(model)
                end
        
                -- @params : entity, componentHash, weaponHash, p3
                GiveWeaponComponentToEntity(weaponObject, GetHashKey(componentName), GetHashKey(weaponData.hashName), true)
                SetModelAsNoLongerNeeded(model)
    
            else
                -- @params : entity, componentHash, weaponHash, p3
                GiveWeaponComponentToEntity(weaponObject, GetHashKey(componentName), GetHashKey(weaponData.hashName), true)
    
            end
    
            IsWeaponComponentModelLoading = false
    
            if Config.Debug then
                print(string.format('Weapon Hash: %s, Weapon Type: %s, Components: [type: %s - selected: %s]', weaponData.hashName, weaponType, componentType, componentName))
            end
    
            TriggerServerEvent("tpz_inventory:setWeaponMetadata", weaponData.value, 'COMPONENT', { componentType, componentName } )
         
            WeaponComponents[componentType] = { name = componentName, index = data.current.value }
    
            -- TriggerServerEvent("tpz_weapons:applyWeaponMod", weaponData.itemId, component, data.current.value )

        else

            IsWeaponComponentModelLoading = false
        end

    end,

    function(data, menu)

        OpenWeaponCustomization(locationIndex, weaponData, weaponObject)
        menu.close()
    end)

end

OpenWeaponComponentsByWeapon = function(locationIndex, weaponData, weaponObject)
    local PlayerData = GetPlayerData()
    
    local elements = {}

    local foundComponents       = GetWeaponComponents(weaponData.hashName)

    local weaponType            = GetWeaponType(GetHashKey(weaponData.hashName))
    local foundSharedComponents = GetWeaponTypeSharedComponents(weaponType)

    local tempComponentList = {}

    if GetTableLength(foundComponents) > 0 then
    
        for index, val in pairs (foundComponents) do 

            table.insert(elements, { 
                value = index, 
                label = Locales['MENU_CUSTOMIZATION_' .. index], 
            })

            tempComponentList[index] = true
        end
    
    end

    if GetTableLength(foundSharedComponents) > 0 then

        for index, val in pairs (foundSharedComponents) do 

            local args = Split(index, '_')
            local componentType = args[1]

            if Locales['MENU_CUSTOMIZATION_' .. componentType] and tempComponentList[componentType] == nil then
                tempComponentList[componentType] = true

                table.insert(elements, { 
                    value = componentType, 
                    label = Locales['MENU_CUSTOMIZATION_' .. componentType], 
                })
                
            end

         
        end

    end

    tempComponentList = nil

    table.insert(elements, { value = 'back', label = Locales['MENU_BACK_BUTTON'], desc = '' })

    MenuData.Open('default', GetCurrentResourceName() .. "weapon_components_main", 'tpz_menu_base',
    {
        title    = Locales['MENU_TITLE'],
        subtext  = Locales['MENU_TITLE_DESCRIPTION'],
        align    = "left",
        elements = elements,
        lastmenu = "MAIN"
    },

    function(data, menu)
        if (data.current == "backup" or data.current.value == "back") then -- go back

            menu.close()

            DeleteEntity(PlayerData.Item.ObjectEntity)

            PlayerData.Item.ObjectEntity      = nil
            PlayerData.Item.ObjectEntityModel = nil
            PlayerData.Item.ObjectWeapon      = false

            Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)	

            OpenWeaponCustomization(locationIndex)
            return
        end

        menu.close()

        OpenWeaponComponentsByComponent(locationIndex, weaponData, weaponObject, data.current.value)
    end,

    function(data, menu)
        DeleteEntity(PlayerData.Item.ObjectEntity)

        PlayerData.Item.ObjectEntity      = nil
        PlayerData.Item.ObjectEntityModel = nil
        PlayerData.Item.ObjectWeapon      = false

        Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)	

        OpenWeaponCustomization(locationIndex)
        menu.close()
    end)

end

function OpenWeaponCustomization(locationIndex)

    local PlayerData = GetPlayerData()
    TaskStandStill(PlayerPedId(), -1)

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_weapons:getPlayerWeapons", function(weaponsList)

        local elements = {}

        if GetTableLength(weaponsList) > 0 then

            local count = 0

            for index, weapon in pairs (weaponsList) do 

                if model_specific_components[string.upper(weapon.item)] then

                    count = count + 1
                    table.insert(elements, { value = weapon.itemId, label = count .. ". " .. weapon.label, desc = "Serial No. " .. weapon.itemId, hashName = string.upper(weapon.item), metadata = weapon.metadata })

                end
            end

        end

        table.insert(elements, { value = 'exit', label = Locales['MENU_EXIT_BUTTON'], desc = '' })

        MenuData.Open('default', GetCurrentResourceName() .. "main", 'tpz_menu_base',
        {
            title    = Locales['MENU_TITLE'],
            subtext  = Locales['MENU_TITLE_DESCRIPTION'],
            align    = "left",
            elements = elements,
            lastmenu = "MAIN"
        },
    
        function(data, menu)
            if (data.current == "backup" or data.current.value == "exit") then -- go back
                menu.close()
                CloseStoreProperly()
                return
            end

           -- local _, weapon = GetCurrentPedWeapon(PlayerPedId(), true, 0, true) 
          
           -- if not weapon or weapon ~= GetHashKey(data.current.hashName) then	
           --     print("not holding this weapon")
           --     return
           -- end

            WeaponComponents = nil
            WeaponComponents = {}

            Citizen.InvokeNative(0x72D4CB5DB927009C, GetHashKey(data.current.hashName), 1, true)

            while not Citizen.InvokeNative(0xFF07CF465F48B830, GetHashKey(data.current.hashName)) do
                Wait(100)
            end
    
            local objectCoords = Config.Stores[locationIndex].CustomizationItemObjectPosition

            local weaponObject = Citizen.InvokeNative(0x9888652B8BA77F73, GetHashKey(data.current.hashName), 1, objectCoords.x, objectCoords.y, objectCoords.z - 3.0, true, 1.0)
            
            --PlaceObjectOnGroundProperly(weaponObject, true)
            
            if GetTableLength(data.current.metadata.components) > 0 then

                local weaponType = GetWeaponType(GetHashKey(data.current.hashName))

                for type, component in pairs (data.current.metadata.components) do

                    local foundComponentIndex = GetComponentIndexByWeaponName(weaponType, data.current.hashName, type, component)
                    WeaponComponents[type] = { name = component, index = foundComponentIndex }

                    local model = Citizen.InvokeNative(0x59DE03442B6C9598, GetHashKey(component) )
    
                    if model then
                        LoadModel(model)
                    end
            
                    GiveWeaponComponentToEntity(weaponObject, GetHashKey(component), GetHashKey(data.current.hashName), true)

                    if model then
                        SetModelAsNoLongerNeeded(model)
                    end
    
                end
    
            end

                
            SetEntityCoords(weaponObject,  objectCoords.x, objectCoords.y, objectCoords.z)
            SetEntityRotation(weaponObject, objectCoords.pitch, objectCoords.roll, objectCoords.yaw, 1, true)

            SetModelAsNoLongerNeeded(data.current.hashName)

            PlayerData.Item.ObjectEntity      = weaponObject
    
            PlayerData.Item.ObjectEntityModel = data.current.hashName
            PlayerData.Item.ObjectWeapon      = true

            menu.close()
            OpenWeaponComponentsByWeapon(locationIndex, data.current, weaponObject)
        end,

        function(data, menu)
            CloseStoreProperly()
            menu.close()
        end)

    end)

end