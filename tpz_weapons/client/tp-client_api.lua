exports('getWeaponsAPI', function()
    local self = {}

  -- @param ammoType : returns nil on throwables, lanterns, torches, knifes, except firing weapons.
  -- @param ammo : returns 0 on lanterns, torches, knifes, except firing weapons and throwables, throwables are always (1).
  -- @param weaponId : returns the unique weapon identifier of the holding weapon when being used.
  -- @param name, hash (string), durability, metadata, obvious returns.
    self.getUsedWeaponData = function()
        return GetUsedWeaponData()
    end

    self.getUsedWeaponsData = function()
        return GetUsedWeaponsData()
    end

    self.clearUsedWeaponData = function(weaponId, refresh) -- 1.1.2
        ClearUsedWeaponData(weaponId, refresh)
    end

    self.setUsedWeaponAmmoType = function(ammoType)
        GetUsedWeaponData().ammoType = ammoType
    end

    self.saveUsedWeaponData = function(weaponId) -- 1.1.2
        SaveUsedWeaponData(weaponId)
    end
    
    self.equipWeapon = function(itemId, hash, ammoType, ammo, label, durability, metadata)
        EquipWeapon(itemId, hash, ammoType, ammo, label, durability, metadata)
    end

    return self
end)
