Cosmic = {}
Cosmic.Config = Config

local VorpCore = {}

TriggerEvent("getCore",function(core)
  VorpCore = core
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()
VORP = exports.vorp_core:vorpAPI()

RegisterServerEvent("Cosmic:CheckGroup")
AddEventHandler("Cosmic:CheckGroup", function()
  local _source = source
	local User = VorpCore.getUser(_source)
	local group = User.getGroup
	if group == "moderator" or group == "admin" then
		TriggerClientEvent("OpenMenu", source)
	end
end)

RegisterServerEvent("Cosmic:CheckSteam")
AddEventHandler("Cosmic:CheckSteam", function()
	local _source = source
  local Character = VorpCore.getUser(_source).getUsedCharacter
  local steamname = GetPlayerName(_source)
  local identifier = Character.identifier
  local charidentifier = Character.charIdentifier
  exports.ghmattimysql:execute('SELECT steamname FROM characters WHERE identifier=@identifier AND charidentifier = @charidentifier', {['identifier'] = identifier, ['charidentifier'] = charidentifier}, function(result)
    if result[1] == nil then
      exports.ghmattimysql:execute("UPDATE characters Set steamname=@steamname WHERE identifier=@identifier AND charidentifier = @charidentifier", {['steamname'] = steamname,['identifier'] = identifier, ['charidentifier'] = charidentifier})
    else
      local steamname2 = result[1].steamname
      if steamname2 ~= steamname then
        exports.ghmattimysql:execute("UPDATE characters Set steamname=@steamname WHERE identifier=@identifier AND charidentifier = @charidentifier", {['steamname'] = steamname,['identifier'] = identifier, ['charidentifier'] = charidentifier})
      end
    end
  end)
end)

RegisterServerEvent("Cosmic:GetPlayers", function()
  local players = GetPlayers()
  local playerList = {}

  for i, player in pairs(players) do
    local player = tonumber(player)
    local name = GetPlayerName(player)
    local playerObject = {
      ['id'] = player,
      ['name'] = name
    }
    table.insert(playerList, playerObject)
  end
  TriggerLatentClientEvent("Cosmic:GetPlayers", source, 200000, playerList)
end)

RegisterServerEvent("Cosmic:GetPermissions")
AddEventHandler("Cosmic:GetPermissions", function()
  local permissionList = {}
  for _, permission in pairs(Cosmic.Permissions.List) do
    local permissionAccess = Cosmic.Permissions.CheckPermission(permission)
    permissionList[permission] = permissionAccess
  end
  TriggerLatentClientEvent("Cosmic:GetPermissions", source, 5000, permissionList)
end)

RegisterServerEvent("Cosmic:GiveWeapon")
AddEventHandler("Cosmic:GiveWeapon", function(player, weapon, ammo, components)
	local _source = source
	local User = VorpCore.getUser(_source)
	local userCharacter = User.getUsedCharacter
	local playername = userCharacter.firstname.. ' ' ..userCharacter.lastname
	local group = User.getGroup
	local targetPlayer = VorpCore.getUser(player)
	local tarChar = targetPlayer.getUsedCharacter
	local tarName = tarChar.firstname.. ' ' ..tarChar.lastname

	if Cosmic.Permissions.CheckPermission('player.rp.weapon.add') then
		TriggerEvent("vorpCore:canCarryWeapons", tonumber(player), 1, function(canCarry)
			if canCarry then
				local message = "`"..playername.."` gave `"..tarName.. "` a `"..weapon.."`"
				VorpInv.createWeapon(tonumber(player), weapon, ammo, components)
				TriggerClientEvent("vorp:TipRight", _source, "You gave " ..tarName..' a '..weapon, 3000)
				TriggerClientEvent("vorp:TipRight", player, playername.." gave you a "..weapon, 3000)
			else
				local message = "`"..playername.."` can't carry anymore weapons"
				TriggerClientEvent("vorp:TipRight", _source, tarName.." Can't carry any more weapons", 3000)
				TriggerClientEvent("vorp:TipRight", player, "You can't carry any more weapons", 3000)
			end
		end)
	else
		TriggerClientEvent("vorp:TipRight", _source, "This is an admin/moderator command only", 2000)
	end
end)

RegisterServerEvent("Cosmic:GiveItem")
AddEventHandler("Cosmic:GiveItem", function(player, itemgiven, qty)
  local _source = source
  local User = VorpCore.getUser(_source) -- Return User with functions and all characters
	local group = User.getGroup
  local Character = User.getUsedCharacter
  local playername = Character.firstname .. ' ' .. Character.lastname
  local inventory = VorpInv.getUserInventory(tonumber(player))
	local tarUser = VorpCore.getUser(tonumber(player))
	local tarChar = tarUser.getUsedCharacter
	local tarName = tarChar.firstname..' '..tarChar.lastname

	if Cosmic.Permissions.CheckPermission('player.rp.item.add') then
		TriggerEvent("vorpCore:canCarryItems", tonumber(player), tonumber(qty), function(canCarry)
			if canCarry then
				if contains2(inventory, itemgiven) then
					for i,item in pairs(inventory) do
						if item.name == itemgiven then
							local carrying = qty + item.count
							if item.limit >= carrying then
								VorpInv.addItem(tonumber(player), itemgiven, qty)
								TriggerClientEvent("vorp:TipRight", _source, "You gave "..tarName..' '..qty..' x '..item.label, 2000)
								TriggerClientEvent("vorp:TipRight", tonumber(player), "You received "..qty..' x '..item.label..' from an Admin', 2000)
							else
								TriggerClientEvent("vorp:TipRight", _source, "That person can't carry anymore "..item.label.." Count: "..item.count..'/'..item.limit, 2000)
								TriggerClientEvent("vorp:TipRight", tonumber(player), "You can't carry more than "..item.limit..' x '..item.label.."Count: "..item.count..'/'..item.limit, 2000)
							end
						end
					end
				else
					local item = itemgiven
					exports.ghmattimysql:execute('SELECT * FROM items WHERE item = @item', {['item'] = item}, function(result)
						if result[1] ~= nil then
							local itemlimit = result[1].limit
							local itemlabel = result[1].label
							if itemlimit >= tonumber(qty) then
								VorpInv.addItem(player, item, qty)
								TriggerClientEvent("vorp:TipRight", _source, "You gave "..tarName..' '..qty..' x '..itemlabel, 2000)
								TriggerClientEvent("vorp:TipRight", player, "You received "..qty..' x '..itemlabel..' from an Admin', 2000)
							else
								TriggerClientEvent("vorp:TipRight", _source, "That person can't more than "..itemlimit..' '..itemlabel, 2000)
								TriggerClientEvent("vorp:TipRight", player, "You can't carry any more than "..itemlimit..' '..itemlabel, 2000)
							end
						end
					end)
				end
			else
				TriggerClientEvent("vorp:TipRight", _source, tarName.." can't carry any more items", 2000)
				TriggerClientEvent("vorp:TipRight", player, "You can't carry any more items", 2000)
			end
		end)
	else
		TriggerClientEvent("vorp:TipRight", _source, "This is an admin/moderator only command", 2000)
	end
end)

function contains2(table, element)
	for k, v in pairs(table) do
		for x, y in pairs(v) do
			  if y == element then
				return true
			end
		end
	end
	return false
end

RegisterServerEvent("Announce")
AddEventHandler("Announce", function(message)
	TriggerClientEvent("vorp:TipBottom", -1, "Announcement: "..message, 8000)
end)

RegisterServerEvent("Bring")
AddEventHandler("Bring", function(target, x, y, z)
	TriggerClientEvent("Bring", target, x, y, z)
end)

RegisterServerEvent("Message")
AddEventHandler("Message", function(target, message)
	TriggerClientEvent("vorp:TipBottom", target, message, 5000)
end)

RegisterServerEvent("KickPlayer")
AddEventHandler("KickPlayer", function(target)
  if Cosmic.Permissions.CheckPermission('player.admin.kick') then
    if Cosmic.Permissions.CheckPermission('immune', target) then
      TriggerClientEvent("vorp:TipRight", source, "The player you attempted to kick is immune.", 3000)
    else
      DropPlayer(target, "You have been kicked by a moderator. Please visit the discord for help.")
      TriggerClientEvent("vorp:TipRight", source, "Player has been kicked.", 3000)
    end
  end
end)

RegisterServerEvent("DelObj")
AddEventHandler("DelObj", function(type)
	local _source = source
	local User = VorpCore.getUser(_source)
	local group = User.getGroup
	local deltype = tonumber(type)

	if group == "admin" then
		if deltype == "on" then
			TriggerClientEvent("ObjectDeleteOn", _source)
		end
		if deltype == "off" then
			TriggerClientEvent("ObjectDeleteOff", _source)
		end
	else
		TriggerClientEvent("vorp:TipRight", _source, "This is an admin only command", 2000)
	end
end)

RegisterCommand("givewep", function(source, args)
  if args ~= nil then
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local playername = Character.firstname.. ' ' ..Character.lastname
    local _source = source
    local group = User.getGroup -- Return user group (not character group)
    local id =   args[1]
    local weaponHash =   tostring(args[2])
    local ammo = {["nothing"] = 0}
    local components =  {["nothing"] = 0}
    if group == "admin" then
      TriggerEvent("vorpCore:canCarryWeapons", tonumber(id), 1, function(canCarry)

        if canCarry then
         -- TriggerEvent("vorpCore:registerWeapon", tonumber(id), weaponHash, ammo, components)
          VorpInv.createWeapon(tonumber(id), weaponHash, ammo, components)

        end
      end)

    else return false
    end
  end
end)

RegisterCommand("tpm", function(source, args)
  local _source = source
  local User = VorpCore.getUser(source) -- Return User with functions and all characters
  local group = User.getGroup -- Return user group (not character group)
  if group == "admin" then
    TriggerClientEvent('syn:tpm2', _source,_source)
  else return false
 end
end)

RegisterCommand("tp", function(source, args)
  local User = VorpCore.getUser(source) -- Return User with functions and all characters
  local group = User.getGroup -- Return user group (not character group)
  if group == "admin" then
    local x =  tonumber(args[1])
    local y =   tonumber(args[2])
    local z =   tonumber(args[3])
    TriggerClientEvent('syn:tp', source,x,y,z)

  else return false
  end
end)

RegisterServerEvent("Cosmic:AddMoney")
AddEventHandler("Cosmic:AddMoney", function(player, type, amount)
  local user = VorpCore.getUser(source)
  local targetPlayer = VorpCore.getUser(player)
  local targetCharacter = targetPlayer.getUsedCharacter
  local characterName = targetCharacter.firstname ..' '.. targetCharacter.lastname
  local group = user.getGroup
  if group == 'moderator' or group == 'admin' then
    VORP.addMoney(player, type, amount)
    TriggerClientEvent("vorp:TipRight", source, string.format('$%s has been given to %s', amount, characterName), 3000)
  end
end)

RegisterServerEvent("Cosmic:RemoveMoney")
AddEventHandler("Cosmic:RemoveMoney", function(player, type, amount)
  local user = VorpCore.getUser(source)
  local targetPlayer = VorpCore.getUser(player)
  local targetCharacter = targetPlayer.getUsedCharacter
  local characterName = targetCharacter.firstname ..' '.. targetCharacter.lastname
  local group = user.getGroup
  if group == 'moderator' or group == 'admin' then
    VORP.removeMoney(player, type, amount)
    TriggerClientEvent("vorp:TipRight", source, string.format('$%s has been removed from %s', amount, characterName), 3000)
  end
end)
