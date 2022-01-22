Citizen.CreateThread(function()
  print('Checking bans table exists.')
  exports.ghmattimysql:execute('SHOW TABLES LIKE \'bans\'', {}, function(results)
    if results[1] == nil then
      print('Bans table doesn\'t exist, creating it...')

      exports.ghmattimysql:execute([[
        CREATE TABLE `bans` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `steam` varchar(100) NOT NULL,
        `license` varchar(255) DEFAULT NULL,
        `discord` varchar(100) DEFAULT NULL,
        `playername` varchar(255) DEFAULT NULL,
        `adminname` varchar(255) DEFAULT NULL,
        `reason` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
        `bantime` varchar(100) NOT NULL,
        `unban` varchar(100) NOT NULL,
        `permanent` tinyint(1) NOT NULL DEFAULT 0,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
      ]])
    end
  end)
end)
