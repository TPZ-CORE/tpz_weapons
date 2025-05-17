-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_weapons:unpackCartidgeBoxItem")
AddEventHandler("tpz_weapons:unpackCartidgeBoxItem", function(item)
    local player = PlayerPedId()

    local dict = 'mech_inspection@cigarette_card@satchel'
    local base = 'exit'

    RequestAnim(dict)

    TaskPlayAnim(player, dict, base, 1.0, 1.0, -1, 31, 0.0, false, false, false, '', false)
    DisplayProgressBar(1000 * 3, Config.CartidgeBoxItems[item].ProgressTextDisplay)

    ClearPedTasksImmediately(player)
    RemoveAnimDict(dict)
end)