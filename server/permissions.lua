Cosmic.Permissions = {}

Cosmic.Permissions.List = {
  'player.teleport.goto',
  'player.teleport.bring',
  'player.admin.spectate',
  'player.admin.message',
  'player.admin.kick',
  'banmanager.ban',
  'banmanager.permanent',
  'banmanager.view',
  'banmanager.unban',
  'player.rp.money.add',
  'player.rp.money.remove',
  'player.rp.gold.add',
  'player.rp.gold.remove',
  'player.rp.item.add',
  'player.utility.god',
  'player.utility.heal',
  'player.utility.revive',
  'player.utility.feed',
  'player.utility.hydrate',
  'player.utility.slap',
  'player.utility.obliterate',
  'option.visibility',
  'option.noclip',
  'option.god',
  'option.waypoint',
  'option.return',
  'option.announce',
  'immune',
}

local VorpCore = {}

TriggerEvent("getCore",function(core)
  VorpCore = core
end)

-- Check player has a specific ace.
Cosmic.Permissions.CheckPermission = function(ace, player)
  local _source = source

  -- Allow for overriding of player
  if player ~= nil then
    _source = player
  end

  -- Add 'cosmic.' prefix to ace.
  if not string.find(ace, 'cosmic.') then
    ace = 'cosmic.' .. ace
  end

  -- Get player group.
  local user = VorpCore.getUser(_source)
  local group = 'group.' .. user.getGroup

  return IsPrincipalAceAllowed(group, ace)
end
