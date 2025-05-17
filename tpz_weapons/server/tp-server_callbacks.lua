local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_weapons:getPlayerWeapons", function(source, cb, data)
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)
 
  local inventory   = xPlayer.getInventoryContents()
  local contents    = {}

  if #inventory > 0 then

    for index, content in pairs (inventory) do 

      -- We check if the content / item is a weapon and has valid itemId.
      if content.type == "weapon" and content.itemId ~= 0 then

        table.insert(contents, content)
        
      end

    end

  end

  return cb(contents)

end)