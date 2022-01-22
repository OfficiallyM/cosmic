Cosmic.Functions = {}

-- Get player identifiers by type.
Cosmic.Functions.GetIdentifier = function(source, idtype)
	local idtype = idtype ~= nil and idtype
	for key, identifier in pairs(GetPlayerIdentifiers(source)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

-- Check if player is banned.
Cosmic.Functions.IsPlayerBanned = function(player)
  local banned = false
  local message = ''

  local result = exports.ghmattimysql:executeSync('SELECT * FROM bans WHERE license=@license', {['@license'] = Cosmic.Functions.GetIdentifier(player, 'license')})
	if result[1] ~= nil then
		local currentTime = tonumber(os.time(os.date("!*t")))
		if currentTime < tonumber(result[1].unban) or result[1].permanent then
			banned = true
			local timeTable = os.date("*t", result[1].unban)
			local reason = result[1].reason

			if result[1].permanent then
				message = 'You are banned from the server:\n' .. reason .. '\n\nYour ban is permanent.'
			else
				message = 'You are banned from the server:\n' .. reason .. '\n\nYour ban will expire on: ' .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. ':' .. timeTable['sec']
			end
		else
			exports.ghmattimysql:execute('DELETE FROM bans WHERE id=@id', {['@id'] = result[1].id})
		end
	end

  return banned, message
end
