Cosmic = {}
Cosmic.Shared = CosmicShared

local players
local systemlogs = ""
local location = nil
local player = nil
local banplayer = nil
local ped = nil
local spectating = false
local visible = true
local source = PlayerId()
local noclip = false
local RelativeMode = Config.Client.RelativeMode
local Speed = Config.Client.Speed
local FollowCam = Config.Client.FollowCam
local isDead = IsPedDeadOrDying(PlayerPedId())
local permissions = {}
local bans = {}

-- Ban related stuff.
local currentBanIndex = 1
local selectedBanIndex = 2
local banTime = 0
local banReason = ''

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if IsControlJustPressed(0, 0x3C3DD371) and not isDead then -- pgdown key
			TriggerServerEvent("Cosmic:CheckGroup")
		end

		if spectating then
			if IsControlJustPressed(0, 0x156F7119) then -- Backspace
				CancelCamera()
			end
		end

		if noclip then
			if IsControlJustPressed(0, 0x156F7119) then -- Backspace
				NoClip()
			end
		end

		if isDead then
			WarMenu.CloseMenu()
			local location = nil
			local player = nil
			local banplayer = nil
			local ped = nil
			local spectating = false
			local visible = true
			local source = PlayerId()
			local noclip = false
			local speed = 1.28
			CancelCamera()
		end
	end
end)

RegisterNetEvent("Cosmic:GetPlayers", function(playerList)
	players = playerList
end)

RegisterNetEvent("Cosmic:GetPed", function(serverPed)
	ped = serverPed
end)

RegisterNetEvent("Cosmic:GetPermissions", function(permissionList)
	permissions = permissionList
end)

RegisterNetEvent("Cosmic:GetPlayers", function(playerList)
	players = playerList
end)

RegisterNetEvent("Cosmic:GetBanList", function(banList)
	bans = banList
end)

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
	TriggerServerEvent("AnnouncePlayer")
	TriggerServerEvent("Cosmic:checksteam")
end)

function string.startsWith(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start
end

function CheckCategoryPermission(category)
	for permission, access in pairs(permissions) do
    if string.startsWith(permission, category) then
      if access then
        return true
      end
    end
  end
  return false
end

RegisterNetEvent("OpenMenu")
AddEventHandler("OpenMenu", function()
	-- Load players.
	players = nil
	TriggerServerEvent("Cosmic:GetPlayers")
	repeat
		Citizen.Wait(10)
	until players

	-- Load bans.
	bans = nil
	TriggerServerEvent("Cosmic:BanList")
	repeat
		Citizen.Wait(10)
	until bans

	if WarMenu.IsAnyMenuOpened() then return end
  WarMenu.OpenMenu('CosmicMenu')
end)

Citizen.CreateThread(function()
	-- Load permissons.
	permissions = nil
	TriggerServerEvent("Cosmic:GetPermissions")
	repeat
		Citizen.Wait(10)
	until permissions

  WarMenu.CreateMenu('CosmicMenu', "Cosmic")
  WarMenu.SetSubTitle('CosmicMenu', 'Admin menu by ~t8~M-~s~')
  WarMenu.SetMenuX('CosmicMenu', 0.062)
	WarMenu.SetMenuWidth('CosmicMenu', 0.2775)

	local serverId = GetPlayerServerId(PlayerId())
	if CheckCategoryPermission('player') then
		WarMenu.CreateSubMenu('PlayerMenu', 'CosmicMenu', 'Player options')
	end
	if CheckCategoryPermission('player.teleport') then
		WarMenu.CreateSubMenu('TeleportMenu', 'PlayerMenu', 'Teleport options')
	end
	if CheckCategoryPermission('player.admin') then
		WarMenu.CreateSubMenu('AdminMenu', 'PlayerMenu', 'Administrative options')
	end
	if CheckCategoryPermission('banmanager') then
		WarMenu.CreateSubMenu('BanMenu', 'AdminMenu', 'Ban player')
	end
	if CheckCategoryPermission('player.rp') then
		WarMenu.CreateSubMenu('RPMenu', 'PlayerMenu', 'RP options')
	end
	if CheckCategoryPermission('player.utility') then
		WarMenu.CreateSubMenu('UtilityMenu', 'PlayerMenu', 'Utility/Fun options')
	end
	if CheckCategoryPermission('player') then
		WarMenu.CreateSubMenu('PlayersList', 'CosmicMenu', 'Player list')
	end
	if CheckCategoryPermission('option') then
		WarMenu.CreateSubMenu('OptionsMenu', 'CosmicMenu', 'Options menu')
	end
	if CheckCategoryPermission('banmanager.view') then
		WarMenu.CreateSubMenu('BanListMenu', 'CosmicMenu', 'Ban list')
		WarMenu.CreateSubMenu('PlayerBanMenu', 'CosmicMenu', 'Player ban options')
	end

  while true do
    if WarMenu.IsMenuOpened('CosmicMenu') then
			if WarMenu.MenuButton("Players", "PlayersList") then end
			if WarMenu.MenuButton("Options", "OptionsMenu") then end
			if WarMenu.MenuButton("Bans", "BanListMenu") then end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('PlayersList') then
			for _, v in pairs(players) do
				if WarMenu.MenuButton(v.id .. " : " .. v.name, "PlayerMenu") then
					v.playerId = GetPlayerFromServerId(v.id)
					v.ped = GetPlayerPed(v.playerId)
					player = v
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('PlayerMenu') then
			if WarMenu.MenuButton("Teleport options", "TeleportMenu") then end
			if WarMenu.MenuButton("Administrative options", "AdminMenu") then end
			if WarMenu.MenuButton("RP options", "RPMenu") then end
			if WarMenu.MenuButton("Utility/Fun menu", "UtilityMenu") then end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('TeleportMenu') then
			if permissions['player.teleport.goto'] then
				if WarMenu.Button('Goto Player') then
					Teleport()
				end
			end

			if permissions['player.teleport.bring'] then
				if WarMenu.Button('Bring Player') then
					Bring()
				end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('AdminMenu') then
			if permissions['player.admin.spectate'] then
				if WarMenu.Button('Spectate Player') then
					Spectate()
				end
			end

			if permissions['player.admin.message'] then
				if WarMenu.Button('Message Player') then
					Message()
					WarMenu.CloseMenu()
				end
			end

			if permissions['player.admin.kick'] then
				if WarMenu.Button('Kick player', "") then
					TriggerServerEvent("KickPlayer", player.id)
					TriggerServerEvent("Log", systemlogs, "Moderator", GetPlayerName(PlayerId()).." Kicked player " .. player.name, 65535)
					TriggerEvent("vorp:TipRight", "Player has been kicked.", 3000)
					WarMenu.CloseMenu()
				end
			end

			if WarMenu.MenuButton("Ban", "BanMenu") then end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('BanMenu') then
			-- Ban length.
			local bantimes = {'1 hour', '6 hours', '12 hours', '1 day', '3 days', '1 week', '1 month', '3 months', '6 months', '1 year'}
			if permissions['banmanager.permanent'] then
				table.insert(bantimes, 'Permanent')
			end

			if WarMenu.ComboBox('', bantimes, currentBanIndex, selectedBanIndex, function(currentIndex, selectedIndex)
				currentBanIndex = currentIndex
				selectedBanIndex = selectedIndex

				-- Update the selected item without having to select the combo box item.
				if (selectedBanIndex ~= currentBanIndex) then
					selectedBanIndex = currentBanIndex
				end
			end) then end

			-- Ban reason.
			if WarMenu.Button('Add ban reason', "") then
				TriggerEvent("vorpinputs:getInput", "Submit", "Enter ban reason", function(cb)
        	banReason = cb
    		end)

				while banReason == nil do
					Wait(0)
				end
			end

			if WarMenu.Button('Ban player', "") then
				local times = {
					[1] = '3600', 			-- 1 hour
					[2] = '21600', 			-- 6 hours
					[3] = '43200', 			-- 12 hours
					[4] = '86400', 			-- 1 day
					[5] = '259200', 		-- 3 days
					[6] = '604800', 		-- 1 week
					[7] = '2678400', 		-- 1 month
					[8] = '8035200', 		-- 3 months
					[9] = '16070400', 	-- 6 months
					[10] = '32140800', 	-- 1 year
					[11] = '0' 					-- Permanent
				}

				local time = times[selectedBanIndex]

				if banReason ~= '' then
					TriggerServerEvent('Cosmic:Ban', player, time, banReason)
				else
					TriggerEvent("vorp:TipRight", "You must specify a ban reason.", 3000)
				end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('RPMenu') then
			if permissions['player.rp.money.add'] then
				if WarMenu.Button('Add money') then
					local amount = nil

					TriggerEvent("vorpinputs:getInput", "Submit", "Enter money amount", function(cb)
	        	amount = cb
	    		end)

					while amount == nil do
						Wait(0)
					end

					if amount ~= 'close' then
						TriggerServerEvent('Cosmic:AddMoney', player.id, 0, amount)
					end
				end
			end

			if permissions['player.rp.money.remove'] then
				if WarMenu.Button('Remove money') then
					local amount = nil

					TriggerEvent("vorpinputs:getInput", "Submit", "Enter money amount", function(cb)
	        	amount = cb
	    		end)

					while amount == nil do
						Wait(0)
					end

					if amount ~= 'close' then
						TriggerServerEvent('Cosmic:RemoveMoney', player.id, 0, amount)
					end
				end
			end

			if permissions['player.rp.gold.add'] then
				if WarMenu.Button('Add gold') then
					local amount = nil

					TriggerEvent("vorpinputs:getInput", "Submit", "Enter gold amount", function(cb)
	        	amount = cb
	    		end)

					while amount == nil do
						Wait(0)
					end

					if amount ~= 'close' then
						TriggerServerEvent('Cosmic:AddMoney', player.id, 1, amount)
					end
				end
			end

			if permissions['player.rp.gold.remove'] then
				if WarMenu.Button('Remove gold') then
					local amount = nil

					TriggerEvent("vorpinputs:getInput", "Submit", "Enter gold amount", function(cb)
	        	amount = cb
	    		end)

					while amount == nil do
						Wait(0)
					end

					if amount ~= 'close' then
						TriggerServerEvent('Cosmic:RemoveMoney', player.id, 1, amount)
					end
				end
			end

			if permissions['player.rp.item.add'] then
				if WarMenu.Button('Add item') then
					local item = nil
					local quantity = nil

					TriggerEvent("vorpinputs:getInput", "Next", "Enter item name", function(cb)
	        	item = cb
	    		end)

					while item == nil do
						Wait(0)
					end

					if item ~= 'close' then
						TriggerEvent("vorpinputs:getInput", "Add", "Enter item quantity", function(cb)
							quantity = cb
						end)

						while quantity == nil do
							Wait(0)
						end

						if quantity ~= 'close' then
							if quantity ~= nil and item ~= nil then
								TriggerServerEvent('Cosmic:GiveItem', player.id, item, quantity)
							end
						end
					end
				end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('UtilityMenu') then
			if permissions['player.utility.god'] then
				if WarMenu.Button('Toggle Godmode') then
					local playerInvincible = GetPlayerInvincible(player.playerId)
					if playerInvincible then
						SetEntityCanBeDamaged(player.ped, true)
						SetEntityInvincible(player.ped, false)
					else
						SetEntityCanBeDamaged(player.ped, false)
						SetEntityInvincible(player.ped, true)
					end
					TriggerEvent("vorp:TipRight", string.format("Toggled godmode %s for player %s", (playerInvincible and "off" or "on"), player.name), 3000)
				end
			end

			if permissions['player.utility.heal'] then
				if WarMenu.Button('Heal') then
					local maxHealth = GetPedMaxHealth(player.ped)
					SetEntityHealth(player.ped, maxHealth)
					TriggerEvent("vorp:TipRight", string.format("Healed player %s", player.name), 3000)
				end
			end

			if permissions['player.utility.revive'] then
				if WarMenu.Button('Revive') then
					TriggerServerEvent("vorp:revivePlayer", player.id);
					TriggerEvent("vorp:TipRight", string.format("Revived player %s", player.name), 3000)
				end
			end

			if permissions['player.utility.feed'] then
				if WarMenu.Button('Feed') then
					TriggerEvent('DevDokus:Metabolism:C:Hunger', 100)
					TriggerEvent("vorp:TipRight", string.format("Fed player %s", player.name), 3000)
				end
			end

			if permissions['player.utility.hydrate'] then
				if WarMenu.Button('Hydrate') then
					TriggerEvent('DevDokus:Metabolism:C:Thirst', 100)
					TriggerEvent("vorp:TipRight", string.format("Hydrated player %s", player.name), 3000)
				end
			end

			if permissions['player.utility.slap'] then
				if WarMenu.Button('Slap') then
					ApplyDamageToPed(player.ped, 1, false, true,true)
					TriggerEvent("vorp:TipRight", string.format("Slapped player %s", player.name), 3000)
				end
			end

			if permissions['player.utility.obliterate'] then
				if WarMenu.Button('Obliterate') then
					local coords = GetEntityCoords(player.ped)
					ForceLightningFlashAtCoords(coords.x, coords.y, coords.z, -1)
					Citizen.Wait(250)
					ApplyDamageToPed(player.ped, 9999, false, true,true)
					TriggerEvent("vorp:TipRight", string.format("OBLITERATED player %s", player.name), 3000)
				end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('OptionsMenu') then
			if permissions['option.visibility'] then
				if WarMenu.Button('Toggle Visibility') then
					if visible then
						SetEntityVisible(PlayerPedId(), false)
						SetEntityCanBeDamaged(PlayerPedId(), false)
						SetEntityInvincible(PlayerPedId(), true)

						TriggerServerEvent("Log", systemlogs, "Visibility", GetPlayerName(PlayerId()).." turned Visibility off.", 65535)
						visible = false
					else
						SetEntityVisible(PlayerPedId(), true)
						SetEntityCanBeDamaged(PlayerPedId(), true)
						SetEntityInvincible(PlayerPedId(), false)
						TriggerServerEvent("Log", systemlogs, "Visibility", GetPlayerName(PlayerId()).." turned Visibility on.", 65535)
						visible = true
					end
					TriggerEvent("vorp:TipRight", string.format("Toggled visibility %s.", (visible and "on" or "off")), 3000)
				end
			end

			if permissions['option.noclip'] then
				if WarMenu.Button("Toggle Noclip") then
					NoClip()
					WarMenu.CloseMenu()
				end
			end

			if permissions['option.god'] then
				if WarMenu.Button('Toggle Godmode') then
					local invincible = GetPlayerInvincible(PlayerId())
					if invincible then
						SetEntityCanBeDamaged(PlayerPedId(), true)
						SetEntityInvincible(PlayerPedId(), false)
					else
						SetEntityCanBeDamaged(PlayerPedId(), false)
						SetEntityInvincible(PlayerPedId(), true)
					end
					TriggerEvent("vorp:TipRight", string.format("Toggled godmode %s.", (invincible and "off" or "on")), 3000)
				end
			end

			if permissions['option.waypoint'] then
				if WarMenu.Button('Teleport to Waypoint') then
					TeleToWaypoint()
				end
			end

			if permissions['option.return'] then
				if WarMenu.Button('Return to location') then
					Return()
				end
			end

			if permissions['option.announce'] then
				if WarMenu.Button('Send Announcement') then
					Announce()
					WarMenu.CloseMenu()
				end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('BanListMenu') then
			-- List banned players.
			for _, ban in pairs(bans) do
				local unbanstring = ''
				if ban.permanent then
					unbanstring = '~ t8 ~ forever ~ s ~'
				else
					local timeTable = ban.unban
					unbanString = timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. ':' .. timeTable['sec']
				end
				if WarMenu.MenuButton(ban.playername .. ' - banned until: ' .. unbanString, "PlayerBanMenu") then
					banplayer = ban
				end
			end

			-- No banned players message.
			if #bans == 0 then
				if WarMenu.MenuButton('No banned players', 'BanListMenu') then end
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('PlayerBanMenu') then
			-- Data about banned player.
			local bantime = banplayer.bantime
			if WarMenu.MenuButton('Ban reason: ' .. banplayer.reason, 'PlayerBanMenu') then end
			if WarMenu.MenuButton('Banned on: ' .. bantime['day'] .. '/' .. bantime['month'] .. '/' .. bantime['year'] .. ' ' .. bantime['hour'] .. ':' .. bantime['min'] .. ':' .. bantime['sec'], 'PlayerBanMenu') then end
			if WarMenu.MenuButton('Banned by: ' .. banplayer.adminname, 'PlayerBanMenu') then end

			-- Menu options.
			if permissions['banmanager.unban'] then
				if WarMenu.Button('Unban') then
					TriggerServerEvent('Cosmic:Unban', banplayer)
					WarMenu.CloseMenu()
				end
			end
			WarMenu.Display()
		end
		Citizen.Wait(0)
	end
end)

function NoClip()
	local ped = PlayerPedId()
	if not noclip then
		noclip = true
		SetPlayerInvincible(ped, true)
		TriggerServerEvent("Log", systemlogs, "No Clip", GetPlayerName(PlayerId()).." turned No Clip on.", 65535)
	else
		noclip = false
		SetPlayerInvincible(ped, false)
		TriggerServerEvent("Log", systemlogs, "No Clip", GetPlayerName(PlayerId()).." turned No Clip off.", 65535)
	end
end

Citizen.CreateThread(function()
	LoadSettings()
	while true do
		Citizen.Wait(0)
		if noclip then
			-- Disable all controls except a few while in noclip mode
			DisableAllControlActions(0)
			EnableControlAction(0, 0x4A903C11) -- FrontendPauseAlternate
			EnableControlAction(0, 0x9720fcee) -- MpTextChatAll
			EnableControlAction(0, 0xA987235F) -- LookLr
			EnableControlAction(0, 0xD2047988) -- LookUd
			EnableControlAction(0, 0x3D99EEC6) -- HorseGunLr
			EnableControlAction(0, 0xBFF476F9) -- HorseGunUd
			EnableControlAction(0, 0xCF8A4ECA) -- RevealHud
			EnableControlAction(0, 0x4AF4D473) -- Del
			EnableControlAction(0, 0x156F7119) -- Backspace
			EnableControlAction(0, 0x7F8D09B8) -- V key

			DisableFirstPersonCamThisFrame()

			-- Get the entity we want to control in noclip mode
			local entity = GetNoClipTarget()

			-- Get the position and heading of the entity
			local x, y, z = table.unpack(GetEntityCoords(entity))
			local h = GetEntityHeading(entity)

			-- Cap the speed between MinSpeed and MaxSpeed
			if Speed > Config.Client.MaxSpeed then
				SetSpeed(Config.Client.MaxSpeed)
			end
			if Speed < Config.Client.MinSpeed then
				SetSpeed(Config.Client.MinSpeed)
			end

			-- Print the current noclip speed on screen
			DrawText(string.format('NoClip Speed: %.1f', Speed), 0.5, 0.90, true)

			-- Change noclip control mode
			if CheckControls(IsDisabledControlJustPressed, 0, Config.Client.ToggleModeControl) then
				ToggleRelativeMode()
			end

			-- Increase/decrease speed
			if CheckControls(IsDisabledControlPressed, 0, Config.Client.IncreaseSpeedControl) then
				SetSpeed(Speed + Config.Client.SpeedIncrement)
			end
			if CheckControls(IsDisabledControlPressed, 0, Config.Client.DecreaseSpeedControl) then
				SetSpeed(Speed - Config.Client.SpeedIncrement)
			end

			-- Move up/down
			if CheckControls(IsDisabledControlPressed, 0, Config.Client.UpControl) then
				z = z + Speed
			end
			if CheckControls(IsDisabledControlPressed, 0, Config.Client.DownControl) then
				z = z - Speed
			end

			-- Toggle visibility.
			if IsControlJustPressed(0, 0x7F8D09B8) then
				local visible = IsEntityVisible(entity)
				SetEntityVisible(entity, not visible)
			end

			if RelativeMode then
				-- Print the coordinates, heading and controls on screen
				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f\nHeading: %.2f', x, y, z, h), 0.01, 0.3, false)

				if FollowCam then
					DrawText('W/S - Move, Spacebar/Shift - Up/Down, Page Up/Page Down/Mouse Wheel - Change speed, Q - Absolute mode, H - Disable Follow Cam, V - Toggle Visibility, Backspace - Disable noclip', 0.5, 0.95, true)
				else
					DrawText('W/S - Move, A/D - Rotate, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed, Q - Absolute mode, H - Enable Follow Cam, V- Toggle Visibility, Backspace - Disable noclip', 0.5, 0.95, true)
				end

				-- Calculate the change in x and y based on the speed and heading.
				local r = -h * math.pi / 180
				local dx = Speed * math.sin(r)
				local dy = Speed * math.cos(r)

				-- Move forward/backward
				if CheckControls(IsDisabledControlPressed, 0, Config.Client.ForwardControl) then
					x = x + dx
					y = y + dy
				end
				if CheckControls(IsDisabledControlPressed, 0, Config.Client.BackwardControl) then
					x = x - dx
					y = y - dy
				end

				if CheckControls(IsDisabledControlJustPressed, 0, Config.Client.FollowCamControl) then
					ToggleFollowCam()
				end

				-- Rotate heading
				if FollowCam then
					local rot = GetGameplayCamRot(2)
					h = rot.z
				else
					if IsDisabledControlPressed(0, Config.Client.LeftControl) then
						h = h + 1
					end
					if IsDisabledControlPressed(0, Config.Client.RightControl) then
						h = h - 1
					end
				end
			else
				-- Print the coordinates and controls on screen
				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f', x, y, z), 0.01, 0.3, false)
				DrawText('W/A/S/D - Move, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed, Q - Relative mode, V - Toggle Visibility, Backspace - Disable noclip', 0.5, 0.95, true)

				h = 0.0

				-- Move North
				if CheckControls(IsDisabledControlPressed, 0, Config.Client.ForwardControl) then
					y = y + Speed
				end

				-- Move South
				if CheckControls(IsDisabledControlPressed, 0, Config.Client.BackwardControl) then
					y = y - Speed
				end

				-- Move East
				if CheckControls(IsDisabledControlPressed, 0, Config.Client.LeftControl) then
					x = x - Speed
				end

				-- Move West
				if CheckControls(IsDisabledControlPressed, 0, Config.Client.RightControl) then
					x = x + Speed
				end
			end

			SetEntityHeading(entity, h)
			SetEntityCoordsNoOffset(entity, x, y, z, noclip, noclip, noclip)
		end
	end
end)

function giveweps(x)
	local ped = PlayerPedId()
	local hash = GetHashKey(x)
	GiveWeaponToPed(ped,hash,1,true,0,13,0,1,1,0x7B9BDCE7,1,1,1)
	SetCurrentPedWeapon(ped,hash,true,13,1,1)
	print(GetCurrentPedWeapon(ped,1,13,1))
end

function GetNoClipTarget()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsIn(ped, false)
	local mnt = GetMount(ped)
	return (veh == 0 and (mnt == 0 and ped or mnt) or veh)
end

function TranslateHeading(entity, h)
	if GetEntityType(entity) == 1 then
		return (h + 180) % 360
	else
		return h
	end
end

function ToggleRelativeMode()
	RelativeMode = not RelativeMode
	SetResourceKvp('relativeMode', tostring(RelativeMode))
end

function ToggleFollowCam()
	FollowCam = not FollowCam
	SetResourceKvp('followCam', tostring(FollowCam))
end

function SetSpeed(value)
	Speed = value
	SetResourceKvp('speed', tostring(Speed))
end

function CheckControls(func, pad, controls)
	if type(controls) == 'number' then
		return func(pad, controls)
	end

	for _, control in ipairs(controls) do
		if func(pad, control) then
			return true
		end
	end

	return false
end

function LoadSettings()
	local relativeMode = GetResourceKvpString('relativeMode')
	if relativeMode ~= nil then
		RelativeMode = relativeMode == 'true'
	end

	local followCam = GetResourceKvpString('followCam')
	if followCam ~= nil then
		FollowCam = followCam == 'true'
	end

	local speed = GetResourceKvpString('speed')
	if speed ~= nil then
		Speed = tonumber(speed)
	end
end

function TeleToWaypoint()
	local ply = PlayerPedId()
	local pCoords = GetEntityCoords(ply)
	lastlocation = pCoords
	local WP = GetWaypointCoords()
	if (WP.x == 0 and WP.y == 0) then
			TriggerEvent("vorp:TipRight", "You didn't set a waypoint", 3000)
	else
		local height = 1
		for height = 1, 1000 do
			SetEntityCoords(ply, WP.x, WP.y, height + 0.0)
			local foundground, groundZ, normal = GetGroundZAndNormalFor_3dCoord(WP.x, WP.y, height + 0.0)
			if foundground then
				SetEntityCoords(ply, WP.x, WP.y, height + 0.0)
				TriggerServerEvent("Log", systemlogs, "TP To Waypoint", GetPlayerName(PlayerId()).." teleported to " ..WP, 65535)
				break
			end
			Wait(25)
		end
	end
end

function Spectate()
	camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	AttachCamToEntity(camera, GetPlayerPed(player.id), 0.0, -3.0, 1.0, false)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1, true, true)
	SetEntityVisible(PlayerPedId(), false)
	SetEntityCanBeDamaged(PlayerPedId(), false)
	SetEntityInvincible(PlayerPedId(), true)
spectating = true
	if GetPlayerName(PlayerId()) ~= player.name then
		TriggerServerEvent("Log", systemlogs, "Spectate", GetPlayerName(PlayerId()).." is spectating "..player.name, 65535)
	end
end

function CancelCamera()
	if GetPlayerName(PlayerId()) ~= player.name then
		TriggerServerEvent("Log", systemlogs, "Spectate", GetPlayerName(PlayerId()).." is no longer spectating "..player.name, 65535)
	end
    RenderScriptCams(true, false, 1, true, true)
    DestroyCam(camera, true)
    DestroyAllCams()
	SetEntityVisible(PlayerPedId(), true)
	SetEntityCanBeDamaged(PlayerPedId(), false)
	SetEntityInvincible(PlayerPedId(), true)
spectating = false
end

function Teleport()
	TriggerServerEvent("Log", systemlogs, "Teleport", GetPlayerName(PlayerId()).." teleported to " ..player.name, 65535)
	local ped = player.ped
	--local coords = GetEntityCoords(player)
	lastlocation = GetEntityCoords(PlayerPedId())
	SetEntityCoords(PlayerPedId(), player.x,player.y,player.z)

end

function Message()
	AddTextEntry("message", "Message:")
	DisplayOnscreenKeyboard(0, "message", "", "", "", "", "", 175)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    if (GetOnscreenKeyboardResult()) then
		TriggerServerEvent("Message", player.id, GetOnscreenKeyboardResult())
		TriggerServerEvent("Log", systemlogs, "Message", GetPlayerName(PlayerId()).." Sent message: " .. GetOnscreenKeyboardResult() .. ". Recipient: " .. player.name, 65535) -- Log example
		TriggerEvent("vorp:TipRight", "Success", "Message sent.", "menu_textures", "menu_icon_tick", 8000)
    end
end

function Announce()
	TriggerEvent("vorpinputs:getInput", "Announcement", "Announcement Message", function(input)
		local message = tostring(input)
		if message == nil then
			TriggerEvent("vorp:TipRight", "Canceled", 2000)
		else
			TriggerServerEvent("Announce", message)
			TriggerServerEvent("Log", systemlogs, "Announcement", GetPlayerName(PlayerId()).." Sent global announcement: " ..message, 65535)
		end
	end)
end

function Bring()
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	TriggerServerEvent("Bring", player.id, x, y, z)
	TriggerServerEvent("Log", systemlogs, "Teleport", GetPlayerName(PlayerId()).." brought player " ..player.name, 65535)
end

function Return()
	TriggerServerEvent("Log", systemlogs, "Return", GetPlayerName(PlayerId()).." returned to " ..lastlocation, 65535)
	SetEntityCoords(PlayerPedId(), lastlocation)
end

function DrawText(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

function GetDistanceFromPlayer(p)
	local ped = GetPlayerPed(p)
	local pCoords = GetEntityCoords(ped)
	local myCoords = GetEntityCoords(PlayerPedId())
	return GetDistanceBetweenCoords(myCoords.x, myCoords.y, myCoords.z, pCoords.x, pCoords.y, pCoords.z, true)
end

RegisterNetEvent('Cosmic:heal')
AddEventHandler('Cosmic:heal', function(id)
    local closestPlayerPed = GetPlayerPed(id)
    local health = GetAttributeCoreValue(closestPlayerPed, 0)
    local newHealth = health + 100
    local stamina = GetAttributeCoreValue(closestPlayerPed, 1)
    local newStamina = stamina + 100
    local health2 = GetEntityHealth(closestPlayerPed)
    local newHealth2 = health2 + 100
    Citizen.InvokeNative(0xC6258F41D86676E0, closestPlayerPed, 0, newHealth) --core
    Citizen.InvokeNative(0xC6258F41D86676E0, closestPlayerPed, 1, newStamina) --core
    SetEntityHealth(closestPlayerPed, newHealth2)
end)
