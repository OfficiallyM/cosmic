-- Print current zone?
RegisterCommand("zone",function()
    local ped_coords = GetEntityCoords(PlayerPedId())
    local x,y,z =  table.unpack(ped_coords + vector3(0.0,0.0,0.0))
    zone = Citizen.InvokeNative(0x43AD8FC02B429D33,x,y,z,-1) --GetMapZoneAtCoords()
    print(zone)
end)

-- Stinky.
RegisterCommand("Stinky",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, -166523388 , 1, 1, 0, 0)
end)

-- Tip hat.
RegisterCommand("tip",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, -1457020913 , 1, 1, 0, 0)
end)

-- Slit throat.
RegisterCommand("Slit",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, 1256841324 , 1, 1, 0, 0)
end)

-- Slow clap.
RegisterCommand("SlwClp",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, 1023735814 , 1, 1, 0, 0)
end)

-- Smh.
RegisterCommand("Smh",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, -653113914 , 1, 1, 0, 0)
end)

-- Spit.
RegisterCommand("Spit",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, -2106738342, 1, 1, 0, 0)
end)

-- Thumbs down.
RegisterCommand("No",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, 1509171361, 1, 1, 0, 0)
end)

-- Thumbs up.
RegisterCommand("Yes",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, 425751659, 1, 1, 0, 0)
end)

-- Wave.
RegisterCommand("Wave",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, -339257980, 1, 1, 0, 0)
end)

-- Middle finger?
RegisterCommand("Bird",function()
  Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 0, 0, 969312568 , 1, 1, 0, 0)
end)

-- Delete vehicle.
RegisterCommand("dv", function()
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, true)
    if IsPedInAnyVehicle(playerPed, true) then
        vehicle = GetVehiclePedIsIn(playerPed, true)
    end
    if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
		DeleteEntity(vehicle)
    end
end)

-- Delete horse.
RegisterCommand("dh", function()
  local playerPed = PlayerPedId()
  local mount   = GetMount(PlayerPedId())

  if IsPedOnMount(playerPed) then
    DeleteEntity(mount)
  end
end)

-- Toggle hud.
local hud = true
RegisterCommand("hud", function(source, args, rawCommand)
  if hud then
	ExecuteCommand("togglechat")
    DisplayRadar(false)
    TriggerEvent("syn_displayrange", false)
    TriggerEvent("vorp:showUi", false)
    hud = false
  else
  	ExecuteCommand("togglechat")
    DisplayRadar(true)
  	TriggerEvent("syn_displayrange", true)
    TriggerEvent("vorp:showUi", true)
    hud = true
  end
end)

-- List players.
TriggerEvent("chat:addSuggestion", "/list", "Lists players on the server (Steam Name - Server ID")
RegisterCommand("list", function()
	local players = GetPlayers()
	for k, v in pairs(players) do
		print(v.id)
		print(v.name)
	end
end)

-- Give weapon command.
TriggerEvent("chat:addSuggestion", "/giveweapon", "Example: /giveweapon [id] [weapon]")
RegisterCommand("giveweapon", function(source, args, rawCommand)
	local player = args[1]
	local weapon = args[2]
	local ammo = {["nothing"] = 0}
	local components = {["nothing"] = 0}

	TriggerServerEvent("GiveWeapon", player, weapon, ammo, components)
end)

-- Give item command.
TriggerEvent("chat:addSuggestion", "/giveitem", "Example: /giveitem [id] [item] [qty]")
RegisterCommand("giveitem", function(source, args, rawCommand)
	local player = args[1]
	local item = args[2]
	local qty = args[3]

	if qty == "" or qty == nil then
		TriggerEvent("vorp:TipRight", "You must enter a quantity", 2000)
	else
		TriggerServerEvent("GiveItem", player, item, qty)
	end
end)
