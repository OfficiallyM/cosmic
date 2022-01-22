-- Ban player.
RegisterNetEvent("Cosmic:Ban")
AddEventHandler("Cosmic:Ban", function(player, time, reason)
  if Cosmic.Permissions.CheckPermission('banmanager.ban') then
    if Cosmic.Permissions.CheckPermission('immune', player.id) then
      TriggerClientEvent("vorp:TipRight", source, 'The player you attempted to ban is immune.', 3000)
      return
    end

    local time = tonumber(time)
    local banExpire = tonumber(os.time(os.date("!*t")) + time)
    local permanent = false

    -- Override expire date for permanent bans.
    if time == 0 then
      banExpire = 0
      permanent = true
    end

    local banTime = tonumber(os.time(os.date("!*t")))

    local steam = Cosmic.Functions.GetIdentifier(player.id, 'steam')
    local license = Cosmic.Functions.GetIdentifier(player.id, 'license')
    local discord = Cosmic.Functions.GetIdentifier(player.id, 'discord')

    exports.ghmattimysql:execute('INSERT INTO bans (steam, license, discord, playername, adminname, reason, bantime, unban, permanent) VALUES (@steam, @license, @discord, @playername, @adminname, @reason, @bantime, @unban, @permanent)', {
      ['@steam'] = steam,
      ['@license'] = license,
      ['@discord'] = discord,
      ['@playername'] = player.name,
      ['@adminname'] = GetPlayerName(source),
      ['@reason'] = reason,
      ['@bantime'] = banTime,
      ['@unban'] = banExpire,
      ['@permanent'] = permanent
    })

    local timeTable = os.date("*t", banExpire)

    -- Announce ban in the chat.
    TriggerClientEvent('chat:addMessage', string.format('ANNOUNCEMENT | %s has been banned: %s', player.name, reason))

    -- Kick the player from the server.
    if (permanent) then
      DropPlayer(player.id, 'You have been banned:\n' .. reason .. '\n\nYour ban is permanent.')
    else
      DropPlayer(player.id, 'You have been banned:\n' .. reason .. '\n\nYour ban will expire on: ' .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. ':' .. timeTable['sec'])
    end
  else
    print('Player does not have the permission to ban people.')
  end
end)

-- Ban player.
RegisterNetEvent("Cosmic:BanList")
AddEventHandler("Cosmic:BanList", function()
  local _source = source

  if Cosmic.Permissions.CheckPermission('banmanager.view') then
    exports.ghmattimysql:execute('SELECT * FROM bans', {}, function(results)
      for id, ban in pairs(results) do
        results[id].unban = os.date("*t", ban.unban)
        results[id].bantime = os.date("*t", ban.bantime)
      end
      TriggerLatentClientEvent("Cosmic:GetBanList", _source, 100000, results)
    end)
  end
end)

-- Unban player.
RegisterNetEvent("Cosmic:Unban")
AddEventHandler("Cosmic:Unban", function(ban)
  if Cosmic.Permissions.CheckPermission('banmanager.unban') then
    exports.ghmattimysql:execute('DELETE FROM bans WHERE id=@id', {['@id'] = ban.id})
    TriggerClientEvent("vorp:TipRight", source, 'Unbanned ' .. ban.playername, 3000)
  end
end)

-- Run when player connects to the server.
local function OnPlayerConnecting(name, setKickReason, deferrals)
  local player = source
  deferrals.defer()

  -- Apparently you need this here?
  Citizen.Wait(0)

  deferrals.update('Checking if you are banned...')

  local banned, reason = Cosmic.Functions.IsPlayerBanned(player)

  if banned then
    deferrals.done(reason)
  else
    deferrals.done()
    Citizen.Wait(1000)
  end
end
AddEventHandler("playerConnecting", OnPlayerConnecting)
