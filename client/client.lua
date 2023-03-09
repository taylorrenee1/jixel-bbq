local QBCore = exports[Config.CoreName]:GetCoreObject()
local removeobj = false
local effect = "ent_amb_stoner_vent_smoke"
local dict = "core"
local bbqModels = {}
local Targets = {}
local Objects = {}
local i = 0
for _, bbq in pairs(Props.BBQ) do
    table.insert(bbqModels, bbq.prop)
end
local ped = GetPlayerPed(PlayerId())
local craftable = {}


CreateThread(function()
    Targets["BBQPit"..i] =
    exports['qb-target']:AddTargetModel(bbqModels, {
        options = {
            { event = "jixel-bbq:client:bbqMenu", icon = "fas fa-burger", label = Loc[Config.Lan].target["start"] },
            { event = "jixel-bbq:packBBQ", icon = "Fas fa-hands", label = Loc[Config.Lan].target["remove"] }, },
        distance = 1.5 })
end)

-----menus-----
RegisterNetEvent('jixel-bbq:client:bbqMenu', function(data)
    local BBQCooking = {
        { header = Loc[Config.Lan].menu["header_bbq"], isMenuHeader = true, },
        { icon = "fas fa-circle-xmark", header = Loc[Config.Lan].menu["close"], txt = "", params = { event = "jixel-bbq:client:Menu:Close", args = data } },
        { icon = "fas fa-plate-wheat", header = Loc[Config.Lan].menu["header_prep"], params = { event = 'jixel-bbq:Crafting', args = { craftable = Crafting.Prepare, header = data.header } }},
        { icon = "fas fa-burger", header = Loc[Config.Lan].menu["header_bbq"], params = { event = 'jixel-bbq:Crafting', args = { craftable = Crafting.BBQ, header = data.header} }},
    }
    exports['qb-menu']:openMenu(BBQCooking)
end)

RegisterNetEvent('jixel-bbq:client:Menu:Close', function() exports['qb-menu']:closeMenu() end)

RegisterNetEvent('jixel-bbq:client:CreateBBQ', function(itemName, prop)
    local Player = PlayerPedId()
    if Config.PrintDebug then print(prop) end
    local inveh, coords, forward = table.unpack({IsPedInAnyVehicle(Player), GetEntityCoords(Player), GetEntityForwardVector(Player)})
    local heading = GetEntityHeading(Player)
    if not inveh then
        ExecuteCommand("e mechanic4")
        QBCore.Functions.Progressbar("bbqprop", Loc[Config.Lan].progressbar["progress_placing"], 2000, false, true,
        { disableMovement = false, disableCarMovement = false, disableMouse = true, disableComabt = true, }, {}, {}, {}, function() -- Done
            Wait(300)
            ExecuteCommand("e c")
            local x, y, z = table.unpack(coords + forward * 1)
            Objects[#Objects+1] = makeProp({prop = prop, coords = vec3(x,y,z), rotation = heading}, true, false, true)
            removeobj = true
            TriggerServerEvent("jixel-bbq:server:CreateBBQ", itemName)
            i = i + 1
        end, function() -- Cancel
            ClearPedTasksImmediately(ped)
            ExecuteCommand("e c")
        end)
    end
end)

RegisterNetEvent('jixel-bbq:packBBQ', function()
    local inveh = IsPedInAnyVehicle(ped)
	local objData = getClosestObjectProp(ped, Props.BBQ)
	if not inveh then
    if removeobj == true then
		ExecuteCommand('e mechanic4')
		QBCore.Functions.Progressbar("deleteobj", "Packing BBQ Pit...", 2000, false, true,
        { disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
			ExecuteCommand('e c')
			DeleteObject(objData.obj)
			triggerNotify(nil, 'BBQ packed away', 'success')
			TriggerServerEvent('jixel-bbq:server:packBBQ', objData.itemname)
			removeobj = false
			Wait(500)
			ClearPedTasks(ped)
		end, function() -- Cancel
			ExecuteCommand('e c')
		    end)
        end
	end
end)

if Config.Menu == "qb" or Config.Menu == "jixel" or Config.Menu == "jim" then Config.img = "" end
RegisterNetEvent('jixel-bbq:Crafting', function(data)
	local Menu = {}
	if Config.Menu == "qb" or Config.Menu == "jixel" or Config.Menu == "jim" then
		Menu[#Menu + 1] = { header = Loc[Config.Lan].menu["header_prep"], txt = "", isMenuHeader = true }
		Menu[#Menu + 1] = { icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].menu["close"], params = { event = "" } }
        Menu[#Menu + 1] = { icon = "fas fa-arrow-left", header = "", txt = Loc[Config.Lan].menu["return"], params = { event = "jixel-bbq:client:bbqMenu", args = data } }
	end
	for i = 1, #data.craftable do
		for k, v in pairs(data.craftable[i]) do
			if k ~= "amount" then
				local text = ""
				if QBCore.Shared.Items[tostring(k)] == nil then
                if Config.PrintDebug then print("^3Error^7: ^2Script can't find item in QB-Core items.lua - ^1"..k.."^7") end
                    return
                  end
                  setheader = QBCore.Shared.Items[tostring(k)].label
				if data.craftable[i]["amount"] ~= nil then setheader = setheader.." x"..data.craftable[i]["amount"] end
				local disable = false
				local checktable = {}
				for l, b in pairs(data.craftable[i][tostring(k)]) do
					if b == 1 then number = "" else number = " x"..b end
					if not QBCore.Shared.Items[l] then print("^3Error^7: ^2Script can't find ingredient item in QB-Core items.lua - ^1"..l.."^7") return end
					text = text.."- "..QBCore.Shared.Items[l].label..number
					if Config.Menu == "ox" then text = text.."\n" end
					if Config.Menu == "qb" or Config.Menu == "jixel" or Config.Menu == "jim" then                        text = text.."<br>" end
					settext = text
					checktable[l] = HasItem(l, b)
				end
				for _, v in pairs(checktable) do if v == false then disable = true break end end
				if not disable then setheader = setheader.." ✔️" end
				Menu[#Menu + 1] = {
                    disabled = disable,
                    image = "nui://"..Config.img..QBCore.Shared.Items[tostring(k)].image,
                    icon = k,
                    header = setheader, txt = settext, --qb-menu
                    title = setheader, description = settext, -- ox_lib
                    event = "jixel-bbq:Crafting:MakeItem", -- <-- fix here
                    args = { item = k, craft = data.craftable[i], craftable = data.craftable, header = data.header }, -- ox_lib
                    params = { event = "jixel-bbq:Crafting:MakeItem", args = { item = k, craft = data.craftable[i], craftable = data.craftable, header = data.header } } -- qb-menu
                }
				settext, setheader = nil
			end
		end
	end
	if Config.Menu == "ox" then
		exports.ox_lib:registerContext({id = 'Crafting', title = data.header, position = 'top-right', options = Menu })
		exports.ox_lib:showContext("Crafting")
	elseif Config.Menu == "qb" or "jixel" or "jim" then
		exports['qb-menu']:openMenu(Menu)
	end
	exports['qb-menu']:openMenu(Menu)
end)

    local propLookup = {
        cookedsausage = Props.Food.SasusageModel,
        porkchop = Props.Food.PorkChop,
        burgerpatty = Props.Food.BurgerModel,
        hamburger = Props.Food.BurgerModel,
        cheeseburger = Props.Food.BurgerModel,
        steak = Props.Food.SteakModel,
        bacon = Props.Food.BaconModel
    }

    RegisterNetEvent('jixel-bbq:Crafting:MakeItem', function(data)
        print("jixel-bbq:Crafting:MakeItem called with data:", json.encode(data.craft))

        local progbar, animDict1, anim1, prop, inveh, pedcoords, itemLabel = "", "", "", "", IsPedInAnyVehicle(ped), GetEntityCoords(ped), QBCore.Shared.Items[data.item].label
        local objData = getClosestObjectProp(ped, Props.BBQ)
        local objCoord = GetEntityCoords(objData.obj);
        local x, y, z = objCoord.x, objCoord.y, objCoord.z + 0.95
        if data.craftable == Crafting.Prepare then
            progbar = Loc[Config.Lan].progressbar["progress_cooking"]
            animDict1 = "amb@prop_human_parking_meter@male@idle_a"
            anim1 = "idle_a"
        elseif data.craftable == Crafting.BBQ then
            progbar = Loc[Config.Lan].progressbar["progress_making"]
            animDict1 = "amb@prop_human_bbq@male@base"
            anim1 = "base"
        else
            progbar = Loc[Config.Lan].progressbar["progress_making"]
            animDict1 = "amb@prop_human_bbq@male@base"
            anim1 = "base"
        end
        if propLookup[data.craft] ~= nil then
            prop = propLookup[data.craft]
            print(prop)
        else
            prop = Props.Food.DefaultModel
        end
        if not inveh then -- Checks if not in vehicle
            local spawnedObj = CreateObject(prop, x, y, z, true, false, false)
            print("Spawned object ID: ", spawnedObj)
            print(objCoord)
            print(GetEntityCoords(ped))
            print(" Coords of :".." X:"..x.." Y:"..y.." Z:"..z)
            -- print("Set object heading: ", heading)
            FreezeEntityPosition(spawnedObj, prop)
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedAtCoord("ent_amb_stoner_vent_smoke", pedcoords.x, pedcoords.y+0.05, pedcoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            QBCore.Functions.Progressbar('making_food', progbar..itemLabel, 5000, false, true,
                { disableMovement = true, disableCarMovement = false, disableMouse = false, disableCombat = false },
                { animDict = animDict1, anim = anim1, flags = 8 }, {}, {}, function()
                    TriggerServerEvent('jixel-bbq:Crafting:GetItem', data.item, data.craft)
                    Wait(500)
                    TriggerEvent("jixel-bbq:Crafting", data)
                    StopParticleFxLooped(particle, true)
                    DeleteObject(spawnedObj)
                end, function() -- Cancel
                    ClearPedTasks(ped)
                    triggerNotify(nil, Loc[Config.Lan].error["cancel"], "error")
                    TriggerEvent('inventory:client:busy:status', false)
                end, data.item)
        else
            -- Display error message if player is in a vehicle
            triggerNotify(nil, Loc[Config.Lan].error["vehicle"], "error")
        end
    end)

RegisterNetEvent('jixel-bbq:client:Eat', function(itemName)
	if itemName == "hamburger" or itemName == "cheeseburger" or itemName == "hotdog" or itemName == "porkchop" or itemName == "bacon" or itemName == "steak" then ExecuteCommand('e burger') end
	QBCore.Functions.Progressbar("eat_something", Loc[Config.Lan].progressbar["eating"]..QBCore.Shared.Items[itemName].label.."..", 5000, false, true,
    { disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
		toggleItem(false, itemName, 1)
        ExecuteCommand('e c')
        TriggerServerEvent("consumables:server:addHunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + QBCore.Shared.Items[itemName].hunger)
        TriggerServerEvent('hud:server:RelieveStress', Config.StressRelief)
	end, function() -- Cancel
		ExecuteCommand('e c')
    end, itemName)
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() or not LocalPlayer.state.isLoggedIn then return end
    for _, v in pairs(Objects) do unloadModel(GetEntityModel(v)) DeleteObject(v) end
    for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
    exports[Config.CoreName]:HideText()
    exports['qb-menu']:closeMenu()
end)