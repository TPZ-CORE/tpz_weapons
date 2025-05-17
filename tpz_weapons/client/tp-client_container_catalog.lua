
local UI = {}

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function CreateStoreUI(newInfo)

   CloseUiappByHash(`SHOP_BROWSING`)

   Wait(200)

    local a = DatabindingAddDataContainerFromPath("", "DynamicCatalogItems")

    UI.cont = DatabindingAddDataContainer(a, "CatalogItemInspection")
    
    UI.f_1 = DatabindingAddDataBool(UI.cont, "isVisible", true) 
    UI.f_2 = DatabindingAddDataHash(UI.cont, "itemLabel", newInfo.itemLabel)

    UI.f_3 = DatabindingAddDataString(UI.cont, "itemDescription", (newInfo.itemDescription or " "))
    UI.f_4 = DatabindingAddDataString(UI.cont, "purchaseLabel", (Locales['STORE_BUY_NOW']))
    UI.f_5 = DatabindingAddDataInt(UI.cont, "purchasePrice", (newInfo.purchasePrice or 1000))
    UI.f_6 = DatabindingAddDataInt(UI.cont, "tokenPrice", (newInfo.tokenPrice or 0))
    UI.f_7 = DatabindingAddDataBool(UI.cont, "isGoldPrice", (newInfo.isGoldPrice or false))
    UI.f_8 = DatabindingAddDataInt(UI.cont, "purchaseModifiedPrice", (newInfo.purchaseModifiedPrice or 2000))
    UI.f_9 = DatabindingAddDataBool(UI.cont, "modifiedPriceVisible", (newInfo.modifiedPriceVisible or false))
    UI.f_10 = DatabindingAddDataBool(UI.cont, "modifiedPriceGold", (newInfo.modifiedPriceGold or false))
    UI.f_11 = DatabindingAddDataBool(UI.cont, "ammoVisible", (newInfo.ammoVisible or false))
    UI.f_12 = DatabindingAddDataInt(UI.cont, "ammoCurrent", (newInfo.ammoCurrent or 1))
    UI.f_13 = DatabindingAddDataInt(UI.cont, "ammoMax", (newInfo.ammoMax or 5))
    UI.f_14 = DatabindingAddDataString(UI.cont, "ammoTextureDictionary", (newInfo.ammoTextureDictionary or "menu_textures"))
    UI.f_15 = DatabindingAddDataString(UI.cont, "ammoTexture", (newInfo.ammoTexture or "log_gang_bag"))
    UI.f_19 = DatabindingAddDataInt(UI.cont, "mailCurrent", (newInfo.mailCurrent or 3))
    UI.f_20 = DatabindingAddDataBool(UI.cont, "mailVisible", (newInfo.mailVisible or false))

    LaunchUiappByHashWithEntry(`SHOP_BROWSING`, -702860656)

end

function UpdateStoreUI(newInfo)

    for i, v in pairs(newInfo) do

        if i == 'itemLabel' then
            DatabindingAddDataHash(UI.cont, "itemLabel", v)

        elseif i == "itemDescription" or i == "purchaseLabel" or i == "ammoTextureDictionary" or i == "ammoTexture" then 
            DatabindingWriteDataStringFromParent(UI.cont, i, v)
        elseif i == "purchasePrice" or i == "tokenPrice" or i == "purchaseModifiedPrice" or i == "ammoCurrent" or i == "ammoMax" or i == "mailCurrent" then 
            DatabindingWriteDataIntFromParent(UI.cont, i, v)
        elseif i == "isGoldPrice" or i == "modifiedPriceVisible" or i == "modifiedPriceGold" or i == "ammoVisible" or i == "mailVisible" then 
            DatabindingWriteDataBoolFromParent(UI.cont, i, v)
        end

    end
    --LaunchUiappByHashWithEntry(`SHOP_BROWSING`, -702860656) -- -649639953 -702860656
end

function CloseUI()
    CloseUiappByHash(`SHOP_BROWSING`)
end