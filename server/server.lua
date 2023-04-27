local QBCore = exports[Config.CoreName]:GetCoreObject()
local BBQOjects = {}

function HasItem(source, items, amount)
	local amount, count = amount or 1, 0
	local Player = QBCore.Functions.GetPlayer(source)
	if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^2Checking if player has required item^7 '^3"..tostring(items).."^7'") end
	for _, itemData in pairs(Player.PlayerData.items) do
		if itemData and (itemData.name == items) then
			if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^2Item^7: '^3"..tostring(items).."^7' ^2Slot^7: ^3"..itemData.slot.." ^7x(^3"..tostring(itemData.amount).."^7)") end
			count += itemData.amount
		end
	end
	if count >= amount then if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^2Items ^5FOUND^7 x^3"..count.."^7") end return true end
	if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^2Items ^1NOT FOUND^7") end    return false
end

RegisterNetEvent('jixel-bbq:cookbeef', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("rawbeef", amount)then
        if Player.Functions.AddItem("steak", amount) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["rawbeef"], "remove", amount)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["steak"], "add", amount)
        else
            Player.Functions.AddItem("rawbeef", amount)
            triggerNotify(nil, Loc[Config.Lan].error["full"], "error", src)
        end
    else
        triggerNotify(nil, Loc[Config.Lan].error["no_meat"], "error", src )
    end
end)

RegisterNetEvent('jixel-bbq:cookbacon', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("rawbacon", amount)then
        if Player.Functions.AddItem("bacon", amount) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["rawbacon"], "remove", amount)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["bacon"], "add", amount)
        else
            Player.Functions.AddItem("rawbacon", amount)
            triggerNotify(nil, Loc[Config.Lan].error["full"], "error", src)
        end
    else
        triggerNotify(nil, Loc[Config.Lan].error["no_meat"], "error", src )
    end
end)

RegisterNetEvent('jixel-bbq:cookpork', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("rawpork", amount)then
        if Player.Functions.AddItem("porkchop", amount) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["rawpork"], "remove", amount)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["porkchop"], "add", amount)
        else
            Player.Functions.AddItem("rawpork", amount)
            triggerNotify(nil, Loc[Config.Lan].error["full"], "error", src)
        end
    else
        triggerNotify(nil, Loc[Config.Lan].error["no_meat"], "error", src )
    end
end)

RegisterNetEvent('jixel-bbq:cooksausage', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("rawsausage", amount)then
        if Player.Functions.AddItem("sausage", amount) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["rawsausage"], "remove", amount)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["sausage"], "add", amount)
        else
            Player.Functions.AddItem("rawsausage", amount)
            triggerNotify(nil, Loc[Config.Lan].error["full"], "error", src)
        end
    else
        triggerNotify(nil, Loc[Config.Lan].error["no_meat"], "error", src )
    end
end)

RegisterNetEvent('jixel-bbq:cookburger', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("rawhamburger", amount)then
        if Player.Functions.AddItem("hamburgerpatty", amount) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["rawhamburger"], "remove", amount)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["hamburgerpatty"], "add", amount)
        else
            Player.Functions.AddItem("rawhamburger", amount)
            triggerNotify(nil, Loc[Config.Lan].error["full"], "error", src)
        end
    else
        triggerNotify(nil, Loc[Config.Lan].error["no_meat"], "error", src )
    end
end)

RegisterNetEvent('jixel-bbq:server:CreateBBQ', function(itemName, netId)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
	BBQOjects[netId] = itemName
    player.Functions.RemoveItem(itemName, 1)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[itemName], "remove")
end)

RegisterNetEvent('jixel-bbq:server:packBBQ', function(netId)
	if not BBQOjects[netId] then return end
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	DeleteEntity(NetworkGetEntityFromNetworkId(netId))
	if not Player then return end
	print(BBQOjects[netId])
	Player.Functions.AddItem(BBQOjects[netId], 1)
	BBQOjects[netId] = nil
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[itemName], "add")
end)

---Crafting

RegisterServerEvent('jixel-bbq:Crafting:GetItem', function(ItemMake, craftable)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	--This grabs the table from client and removes the item requirements
	local amount = 1
	if craftable then
		if craftable["amount"] then amount = craftable["amount"] end
		for k, v in pairs(craftable[ItemMake]) do TriggerEvent("jixel-bbq:server:toggleItem", false, tostring(k), v, src) end
	end
	--This should give the item, while the rest removes the requirements
	TriggerEvent("jixel-bbq:server:toggleItem", true, ItemMake, amount, src)
end)

RegisterNetEvent('jixel-bbq:server:toggleItem', function(give, item, amount, newsrc)
	local src = newsrc or source
	local amount = amount or 1
	local remamount = amount
	if not give then
		if HasItem(src, item, amount) then -- check if you still have the item
			if QBCore.Functions.GetPlayer(src).Functions.GetItemByName(item).unique then -- If unique item, keep removing until gone
				while remamount > 0 do
					QBCore.Functions.GetPlayer(src).Functions.RemoveItem(item, 1)
					remamount -= 1
				end
				TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", amount) -- Show removal item box when all are removed
				return
			end
			if QBCore.Functions.GetPlayer(src).Functions.RemoveItem(item, amount) then
				if Config.Debug then print("^5Debug^7: ^1Removing ^2from Player^7(^2"..src.."^7) '^6"..QBCore.Shared.Items[item].label.."^7(^2x^6"..(amount or "1").."^7)'") end
				TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", amount)
			end
		else TriggerEvent("jixel-bbq:server:DupeWarn", item, src) end -- if not boot the player
	elseif give then
		if QBCore.Functions.GetPlayer(src).Functions.AddItem(item, amount) then
			if Config.Debug then print("^5Debug^7: ^4Giving ^2Player^7(^2"..src.."^7) '^6"..QBCore.Shared.Items[item].label.."^7(^2x^6"..(amount or "1").."^7)'") end
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
		end
	end
end)

RegisterNetEvent("jixel-bbq:server:DupeWarn", function(item, newsrc)
	local src = newsrc or source
	local P = QBCore.Functions.GetPlayer(src)
	print("^5DupeWarn: ^1"..P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname.."^7(^1"..tostring(src).."^7) ^2Tried to remove item ^7('^3"..item.."^7')^2 but it wasn't there^7")
	DropPlayer(src, "Kicked for attempting to duplicate items")
	print("^5DupeWarn: ^1"..P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname.."^7(^1"..tostring(src).."^7) ^2Dropped from server for item duplicating^7")
end)

if not Config.JimConsumables then
	CreateThread(function()
        local food = { "hotdog", "hamburger", "cheeseburger", "porkchop", "bacon", "steak"}
		for _, v in pairs(food) do QBCore.Functions.CreateUseableItem(v, function(source, item) TriggerClientEvent('jixel-bbq:client:Eat', source, item.name) end) end
	end)
end

CreateThread(function()
    print(Props.BBQ)
    for _, v in pairs(Props.BBQ) do
        QBCore.Functions.CreateUseableItem(v.itemName, function(source, item)
            TriggerClientEvent('jixel-bbq:client:CreateBBQ', source, item.name, v.prop) -- pass prop value here
        end)
    end
end)
