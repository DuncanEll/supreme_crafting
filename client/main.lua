local QBCore = exports['qb-core']:GetCoreObject()
PlayerData = {}

Citizen.CreateThread(function()
    while PlayerData.citizenid == nil do
        PlayerData = QBCore.Functions.GetPlayerData()
        Citizen.Wait(1)
    end
end)


Recipes = {}

RegisterNetEvent("supreme_crafting:client:Update", function(recipes_data)
    Recipes = recipes_data
end)


RegisterCommand('craft', function()
    local playerData = QBCore.Functions.GetPlayerData()

    local showMenu = false
    local contextData = {
        id = 'crafting_menu',
        title = 'Crafting',
        options = {}
    }

    for k, v in pairs(Recipes) do
        if playerData.citizenid == v.owner then
            if v.recipe_name == "recipe_pistol" then
                local weapon = Config.ContextItems.pistol.name
                local label = Config.ContextItems.pistol.label
                table.insert(contextData.options, {
                    title = label,
                    description = GenerateDescription({
                        {itemname = 'Water', amount = 10},
                        {itemname = 'Burger', amount = 10},
                    }),
                    image = "nui://ox_inventory/web/images/"..weapon..".png",
                    event = "supreme_crafting:client:Craft",
                    args = {
                        item = {
                            {itemname = 'water', amount = 10},
                            {itemname = 'burger', amount = 10},
                        },
                        weapon = weapon,
                        craftingTime = 2000,
                        craftingLabel = "Crafting " .. label
                    }
                })
                showMenu = true
            elseif v.recipe_name == "recipe_assaultrifle" then
                local weapon = Config.ContextItems.assaultrifle.name
                local label = Config.ContextItems.assaultrifle.label
                table.insert(contextData.options, {
                    title = label,
                    description = GenerateDescription({
                        {itemname = 'Water', amount = 1},
                        {itemname = 'Burger', amount = 1},
                    }),
                    image = "nui://ox_inventory/web/images/"..weapon..".png",
                    event = "supreme_crafting:client:Craft",
                    args = {
                        item = {
                            {itemname = 'water', amount = 1},
                            {itemname = 'burger', amount = 1},
                        },
                        weapon = weapon,
                        craftingTime = 2000,
                        craftingLabel = "Crafting " .. label
                    }
                })
                showMenu = true
            end
        end
    end

    if not showMenu then
        table.insert(contextData.options, {
            title = "You don't have any recipes",
            description = '',
            event = "",
            args = {}
        })
        showMenu = true
    end

    if showMenu then
        lib.registerContext(contextData)
        lib.showContext('crafting_menu')
    end
end)

RegisterNetEvent('supreme_crafting:client:Craft', function(data)
    local weapon = data.weapon

    local playerData = QBCore.Functions.GetPlayerData().items

    local hasRequiredItems = true
    for _, item in ipairs(data.item) do
        if not HasItem(playerData, item.itemname, item.amount) then
            hasRequiredItems = false
            break
        end
    end

    if hasRequiredItems then
        if lib.progressBar({
            duration = data.craftingTime,
            label = data.craftingLabel,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped'
            },
        }) then
            TriggerServerEvent('supreme_crafting:server:Craft', data, weapon)
        else
            TriggerEvent('QBCore:Notify', 'Cancelled', 'error')
        end
    else
        TriggerEvent('QBCore:Notify', 'You do not have the required items.', 'error')
    end
end)

function HasItem(playerData, itemName, amount)
    for _, item in ipairs(playerData) do
        if item.name == itemName and item.count and item.count >= amount then
            return true
        end
    end
    return false
end

function GenerateDescription(items)
    local description = "Required Items:\n"
    for _, item in ipairs(items) do
        description = description .. item.itemname .. " = " .. item.amount .. "\n"
    end
    return description
end











