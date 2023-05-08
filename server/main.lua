Recipes = {}
local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('QBCore:Server:PlayerLoaded', function()
    Wait(1000) -- 1 second should be enough to do the preloading in other resources
    updateRecipes()
end)

function updateRecipes()
    TriggerClientEvent("supreme_crafting:client:Update", -1, _G["Recipes"])
end

MySQL.ready(function()
    local database = MySQL.Sync.fetchAll('SELECT * FROM recipes')
    local recipes = {}  

    for k, v in pairs(database) do
        print(v.owner)
        print(v.recipe_name)
        local identifier = v.owner
        local recipe = v.recipe_name
        table.insert(recipes, { owner = identifier, recipe_name = recipe })  
    end

    _G["Recipes"] = recipes

    Citizen.Wait(100)
    updateRecipes()
end)

for _, recipeName in ipairs(Config.UseableItems) do
    QBCore.Functions.CreateUseableItem('recipe_' .. recipeName, function(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local identifier = xPlayer.PlayerData.citizenid
        
        local hasRecipe = false
        for _, recipe in pairs(Recipes) do
            if recipe.owner == identifier and recipe.recipe_name == 'recipe_' .. recipeName then
                hasRecipe = true
                break
            end
        end
        
        if hasRecipe then
            TriggerClientEvent('QBCore:Notify', source, 'You already have this recipe.', 'error')
        else

            MySQL.Async.insert('INSERT INTO recipes (owner, recipe_name) VALUES (@owner, @recipe_name)',
                {['owner'] = identifier, ['recipe_name'] = 'recipe_' .. recipeName},
                function()
    
                    local database = MySQL.Sync.fetchAll('SELECT * FROM recipes')
                    local recipes = {}
                    
                    for k, v in pairs(database) do
                        local identifier = v.owner
                        local recipe = v.recipe_name
                        table.insert(recipes, { owner = identifier, recipe_name = recipe })
                    end
                    
                    _G["Recipes"] = recipes
                    
                    Citizen.Wait(100)
                    updateRecipes()
                end
            )
            xPlayer.Functions.RemoveItem('recipe_'..recipeName, 1)
            TriggerClientEvent('QBCore:Notify', source, Config.Notification)
        end
    end)
end

RegisterServerEvent('supreme_crafting:server:Craft')
AddEventHandler('supreme_crafting:server:Craft', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if player then
        local hasRequiredItems = true
        for _, item in ipairs(data.item) do
            if not player.Functions.RemoveItem(item.itemname, item.amount) then
                hasRequiredItems = false
                break
            end
        end

        if hasRequiredItems then
            player.Functions.AddItem(data.weapon, 1)
            TriggerClientEvent('QBCore:Notify', src, 'Crafting successful!', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'You do not have the required items.', 'error')
        end
    end
end)


