TGNS = {}
local scheduledActions = {}
local scheduledActionsErrorCount = 0

TGNS.HIGHEST_EVENT_HANDLER_PRIORITY = 9
TGNS.VERY_HIGH_EVENT_HANDLER_PRIORITY = 7
TGNS.NORMAL_EVENT_HANDLER_PRIORITY = 5
TGNS.VERY_LOW_EVENT_HANDLER_PRIORITY = 3
TGNS.LOWEST_EVENT_HANDLER_PRIORITY = 1

function TGNS.GetSimpleServerName()
	local tacticalGamerServerNamePrefix = "TacticalGamer.com - "
	local result = Server.GetName()
	if TGNS.Contains(result, tacticalGamerServerNamePrefix) then
		result = TGNS.Substring(result, string.len(tacticalGamerServerNamePrefix) + 1)
	end
	return result
end

function TGNS.ReplaceClassMethod(className, methodName, method)
	return DAK:Class_ReplaceMethod(className, methodName, method)
end

function TGNS.Replace(original, pattern, replace)
	local result = string.gsub(original, pattern, replace)
	return result
end

function TGNS.GetNextMapName()
	local result = MapCycle_GetNextMapInCycle().map
	return result
end

function TGNS.Substring(s, startIndex, length)
	local endIndex = length ~= nil and startIndex + length - 1 or nil
	local result = string.sub(s, startIndex, endIndex)
	Shared.Message("Substring result = " .. tostring(result))
	return result
end

function TGNS.Truncate(s, length)
	local result = TGNS.Substring(s, 1, length)
	return result
end

function TGNS.ToLower(s)
	local result = string.lower(s)
	return result
end

function TGNS.GetCurrentMapName()
	local result = Shared.GetMapName()
	return result
end

function TGNS.ConvertMinutesToSeconds(minutes)
	local result = minutes * 60
	return result
end

function TGNS.SwitchToMap(mapName)
	MapCycle_ChangeMap(mapName)
end

function TGNS.GetClientList(predicate)
	local result = TGNS.GetClients(TGNS.GetPlayerList())
	if predicate ~= nil then
		result = TGNS.Where(result, predicate)
	end
	return result
end

function TGNS.GetPlayerTotalCost(player)
	local result = TGNS.GetPlayerClassPurchaseCost(player) + TGNS.GetMarineWeaponsTotalPurchaseCost(player) + TGNS.GetPlayerResources(player)
	return result
end

function TGNS.SecondsToClock(sSeconds)
	local result = "00:00:00"
	local nSeconds = tonumber(sSeconds)
	if nSeconds ~= 0 then
		nHours = string.format("%02.f", math.floor(nSeconds/3600));
		nMins = string.format("%02.f", math.floor(nSeconds/60 - (nHours*60)));
		nSecs = string.format("%02.f", math.floor(nSeconds - nHours*3600 - nMins *60));
		result = nHours..":"..nMins..":"..nSecs
	end
	return result
end

function TGNS.KillPlayer(player)
	player:Kill(nil, nil, player:GetOrigin())
end

function TGNS.GetPlayerClassName(player)
	local result = player:GetClassName()
	return result
end

function TGNS.GetMarineWeaponsTotalPurchaseCost(player)
	local marineWeaponPurchaseCosts = {
      [Welder.kMapName] = kWelderCost,
      [LayMines.kMapName] = kMineCost,
      [Shotgun.kMapName] = kShotgunCost,
      [GrenadeLauncher.kMapName] = kGrenadeLauncherCost,
      [Flamethrower.kMapName] = kFlamethrowerCost
    }
	local result = 0
	TGNS.DoForPairs(marineWeaponPurchaseCosts, function(key,value)
		if player:GetWeapon(key) then
			result = result + value
		end
	end)
	return result
end

function TGNS.GetPlayerClassPurchaseCost(player)
	local playerClassNamePurchaseCosts = {
      ["JetpackMarine"] = kJetpackCost,
      ["Onos"] = kOnosCost,
      ["Fade"] = kFadeCost,
      ["Lerk"] = kLerkCost,
      ["Gorge"] = kGorgeCost
    }
	local exoLayoutNamePurchaseCosts = {
      ["ClawMinigun"] = kExosuitCost,
      ["ClawRailgun"] = kClawRailgunExosuitCost,
      ["MinigunMinigun"] = kDualExosuitCost
    }
	local playerClassNameResCost
	if (player.layout) then
		playerClassNameResCost = exoLayoutNamePurchaseCosts[player.layout]
	else
		playerClassNameResCost = playerClassNamePurchaseCosts[TGNS.GetPlayerClassName(player)]
	end
	local result = playerClassNameResCost ~= nil and playerClassNameResCost or 0
	return result
end

function TGNS.IsGameInCountdown()
	local result = GetGamerules():GetGameState() == kGameState.Countdown
	return result
end

function TGNS.IsGameInProgress()
	local result = GetGamerules():GetGameState() == kGameState.Started
	return result
end

function TGNS.RoundPositiveNumber(num, numberOfDecimalPlaces)
	local mult = 10^(numberOfDecimalPlaces or 0)
	local result = math.floor(num * mult + 0.5) / mult
	return result
end

function TGNS.GetPlayerResources(player)
	local result = player:GetResources()
	return result
end

function TGNS.SetPlayerResources(player, value)
	player:SetResources(value)
end

function TGNS.RemoveAllMatching(elements, element)
	for r = #elements, 1, -1 do
		if elements[r] == element then
			table.remove(elements, r)
		end
	end
end

function TGNS.DestroyEntity(entity)
	DestroyEntity(entity)
end

function TGNS.KillTeamEntitiesExcept(className, teamNumber, entityToKeep)
	local entities = TGNS.GetEntitiesForTeam(className, teamNumber)
	TGNS.DoFor(entities, function (e)
		if e ~= entityToKeep then
			TGNS.DestroyEntity(e)
		end
	end)
end

function TGNS.GetEntitiesForTeam(className, teamNumber)
	local result = GetEntitiesForTeam(className, teamNumber)
	return result
end

function TGNS.EntityIsCommandStructure(entity)
	local result = false
	if entity ~= nil then
		local entityClassName = entity:GetClassName()
		result = entityClassName == "CommandStation" or entityClassName == "Hive"
	end
	return result
end

function TGNS.DestroyAllEntities(className, teamNumber)
	local entities = TGNS.GetEntitiesForTeam(className, teamNumber)
	TGNS.DoFor(entities, function(e) TGNS.DestroyEntity(e) end)
end

function TGNS.IsTournamentMode()
	local result = DAK:GetTournamentMode()
	return result
end

function TGNS.AddSteamIDToGroup(steamId, groupName)
	DAK:AddSteamIDToGroup(steamId, groupName)
end

function TGNS.RemoveSteamIDFromGroup(steamId, groupName)
	DAK:RemoveSteamIDFromGroup(steamId, groupName)
end

function TGNS.EnhancedLog(message)
	DAK:ExecutePluginGlobalFunction("enhancedlogging", EnhancedLogMessage, message)
end

function TGNS.VerifyClient(client)
	local result = DAK:VerifyClient(client)
	return result
end

function TGNS.ClientIsInGroup(client, groupName)
	local result = DAK:GetClientIsInGroup(client, groupName)
	return result
end

function TGNS.IsPlayerAFK(player)
	local result = DAK:IsPlayerAFK(player)
	return result
end

function TGNS.IsPluginEnabled(pluginName)
	local result = DAK:IsPluginEnabled(pluginName)
	return result
end

function TGNS.ClientCanRunCommand(client, command)
	local result = DAK:GetClientCanRunCommand(client, command)
	return result
end

function TGNS.RegisterPluginConfig(pluginName, pluginVersion, defaultConfig, defaultLanguageStrings)
	defaultConfig = defaultConfig ~= nil and defaultConfig or {}
	defaultLanguageStrings = defaultLanguageStrings ~= nil and defaultLanguageStrings or {}
	DAK:RegisterEventHook("PluginDefaultConfigs", {PluginName = pluginName, DefaultConfig = function() return defaultConfig end })
	DAK:RegisterEventHook("PluginDefaultLanguageDefinitions", function() return defaultLanguageStrings end)
end

function TGNS.GetConcatenatedStringOrEmpty(...)
	local result = ""
	local concatenation = StringConcatArgs(...)
	if concatenation then
		result = concatenation
	end
	return result
end

function TGNS.RegisterCommandHook(command, handler, helpText, availableToAllPlayers)
	DAK:CreateServerAdminCommand(command, handler, helpText, availableToAllPlayers)
end

function TGNS.RegisterEventHook(eventName, handler, priority)
	DAK:RegisterEventHook(eventName, handler, priority ~= nil and priority or TGNS.NORMAL_EVENT_HANDLER_PRIORITY)
end

function TGNS.HasNonEmptyValue(stringValue)
	local result = stringValue ~= nil and stringValue ~= ""
	return result
end

function TGNS.PlayerIsRookie(player)
	local result = player:GetIsRookie()
	return result
end

function TGNS.GetClientCommunityDesignationCharacter(client)
	local result
	if TGNS.IsClientSM(client) then
		result = "S"
	elseif TGNS.IsPrimerOnlyClient(client) then
		result = "P"
	else
		result = "?"
	end
	return result
end

function TGNS.Contains(s, part)
	return s:find(part)
end

function TGNS.StartsWith(s,part)
   return string.sub(s,1,string.len(part))==part
end

function TGNS.EndsWith(s, part)
	return #s >= #part and s:find(part, #s-#part+1, true) and true or false
end

function TGNS.RespawnPlayer(player)
	GetGamerules():RespawnPlayer(player)
end

function TGNS.SendToRandomTeam(player)
	local playerList = TGNS.GetPlayerList()
	local marinesCount = #TGNS.GetMarineClients(playerList)
	local aliensCount = #TGNS.GetAlienClients(playerList)
	local teamNumber
	if marinesCount == aliensCount then
		teamNumber = math.random(1,2)
	else
		teamNumber = marinesCount < aliensCount and 1 or 2
	end
	TGNS.SendToTeam(player, teamNumber)
end

function TGNS.SendToTeam(player, teamNumber)
	GetGamerules():JoinTeam(player, teamNumber)
end

function TGNS.Join(list, delimiter)
  if #list == 0 then 
    return "" 
  end
  local string = list[1]
  for i = 2, #list do 
    string = string .. delimiter .. list[i] 
  end
  return string
end

function TGNS.GetPlayerTeamName(player)
	local result = TGNS.GetTeamName(TGNS.GetPlayerTeamNumber(player))
	return result
end

function TGNS.GetPlayerTeamNumber(player)
	local result = player:GetTeamNumber()
	return result
end

function TGNS.PlayersAreTeammates(player1, player2)
	local result = TGNS.GetPlayerTeamNumber(player1) == TGNS.GetPlayerTeamNumber(player2)
	return result
end

function TGNS.TableValueCount(tt, item)
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end

function TGNS.TableUnique(tt)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(TGNS.TableValueCount(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end

function TGNS.ScheduleAction(delayInSeconds, action)
	local scheduledAction = {}
	scheduledAction.when = Shared.GetTime() + delayInSeconds
	scheduledAction.what = action
	table.insert(scheduledActions, scheduledAction)
end

local function ProcessScheduledActions()
	for r = #scheduledActions, 1, -1 do
		local scheduledAction = scheduledActions[r]
		if scheduledAction.when < Shared.GetTime() then
			local success, result = xpcall(scheduledAction.what, debug.traceback)
			if success then
				table.remove(scheduledActions, r)
			else
				scheduledActionsErrorCount = scheduledActionsErrorCount + 1
				if scheduledActionsErrorCount < 100 then
					local errorMessage = string.format("ScheduledAction Error (%s, %s): %s", scheduledActionsErrorCount, Shared.GetTime(), result)
					Shared.Message(errorMessage)
					TGNS.EnhancedLog(errorMessage)
				else
					table.remove(scheduledActions, r)
				end
			end
		end
	end
end

local function CommonOnServerUpdate(deltatime)
	ProcessScheduledActions()
end
TGNS.RegisterEventHook("OnServerUpdate", CommonOnServerUpdate)

function TGNS.PlayerIsOnTeam(player, team)
	local result = player:GetTeam() == team
	return result
end

function TGNS.IsGameStartingState(gameState)
	local result = gameState == kGameState.Started
	return result
end

function TGNS.IsGameInPreGame()
	local result = GetGamerules():GetGameState() == kGameState.PreGame
	return result
end

function TGNS.IsGameWinningState(gameState)
	local result = gameState == kGameState.Team1Won or gameState == kGameState.Team2Won
	return result
end

function TGNS.IsGameplayTeam(teamNumber)
	local result = teamNumber == kMarineTeamType or teamNumber == kAlienTeamType
	return result
end

function TGNS.GetTeamName(teamNumber)
	local result
	if teamNumber == kTeamReadyRoom then
		result = "Ready Room"
	elseif teamNumber == kMarineTeamType then
		result = "Marines"
	elseif teamNumber == kAlienTeamType then
		result = "Aliens"
	elseif teamNumber == kSpectatorIndex then
		result = "Spectator"
	end
	return result
end

function TGNS.IsPlayerReadyRoom(player)
	local result = player:GetTeamNumber() == kTeamReadyRoom
	return result
end

function TGNS.IsPlayerSpectator(player)
	local result = player:isa("Spectator") and player:GetTeamNumber() == kSpectatorIndex
	return result
end

function TGNS.GetNumericValueOrZero(countable)
	local result = countable == nil and 0 or countable
	return result
end

function TGNS.GetClientName(client)
	local result = client:GetControllingPlayer():GetName()
	return result
end

function TGNS.DoFor(elements, elementAction)
	if elements ~= nil then
		for i = 1, #elements, 1 do
			if elements[i] ~= nil then
				if elementAction(elements[i]) then
					break
				end
			end
		end
	end
end

function TGNS.DoForReverse(elements, elementAction)
	if elements ~= nil then
		for r = #elements, 1, -1 do
			if elements[r] ~= nil then
				if elementAction(elements[r], r) then
					break
				end
			end
		end
	end
end

function TGNS.DoForPairs(t, pairAction)
	if t ~= nil then
		for key, value in pairs(t) do
			if value ~= nil then
				if pairAction(key, value) then
					break
				end
			end
		end
	end
end

function TGNS.Where(elements, predicate)
	local result = {}
	TGNS.DoFor(elements, function(e)
		if predicate ~= nil and predicate(e) then
			table.insert(result, e)
		end
	end)
	return result
end

function TGNS.Any(elements, predicate)
	local result = #TGNS.Where(elements, predicate) > 0
	return result
end

function TGNS.IsClientCommander(client)
	local result = false
	if client ~= nil then
		local player = client:GetControllingPlayer()
		if player ~= nil then
			result = player:GetIsCommander()
		end
	end
	return result	
end

function TGNS.HasClientSignedPrimer(client)
	local result = false
	if client ~= nil then
		result = TGNS.ClientCanRunCommand(client, "sv_hasprimersignature")
	end
	return result
end

function TGNS.IsClientAdmin(client)
	local result = false
	if client ~= nil then
		result = TGNS.ClientCanRunCommand(client, "sv_hasadmin")
	end
	return result
end

function TGNS.IsClientGuardian(client)
	local result = false
	if client ~= nil then
		result = not TGNS.IsClientAdmin(client) and TGNS.ClientCanRunCommand(client, "sv_isguardian")
	end
	return result
end

function TGNS.IsClientTempAdmin(client)
	local result = false
	if client ~= nil then
		result = not TGNS.IsClientAdmin(client) and TGNS.ClientCanRunCommand(client, "sv_istempadmin")
	end
	return result
end

function TGNS.IsClientSM(client)
	local result = false
	if client ~= nil then
		result = TGNS.ClientCanRunCommand(client, "sv_hassupportingmembership")
	end
	return result
end

function TGNS.IsClientStranger(client)
	local result = not TGNS.IsClientSM(client) and not TGNS.HasClientSignedPrimer(client)
	return result
end

function TGNS.PlayerAction(client, action)
	local player = client:GetControllingPlayer()
	return action(player)
end

function TGNS.GetPlayerName(player)
	return player:GetName()
end

function TGNS.GetClientName(client)
	local result = TGNS.PlayerAction(client, TGNS.GetPlayerName)
	return result
end

function TGNS.ClientAction(player, action)
	local client = Server.GetOwner(player)
	if client then
		return action(client)
	end
end

function TGNS.ConsolePrint(client, message, prefix)
	if client ~= nil then
		if prefix == nil then
			prefix = "TGNS"
		end
		if message == nil then
			message = ""
		end
		if not TGNS.GetIsClientVirtual(client) then
			ServerAdminPrint(client, "[" .. prefix .. "] " .. message)
		end
	end
end

function TGNS.GetClientSteamId(client)
	result = client:GetUserId()
	return result
end

function TGNS.DoForClientsWithId(clients, clientAction)
	for i = 1, #clients, 1 do
		local client = clients[i]
		local steamId = TGNS.GetClientSteamId(client)
		if steamId == nil then
			// todo mlh report to admins so they can make sure there aren't rampant problems??
		else
			clientAction(client, steamId)
		end
	end
end

function TGNS.GetClientNameSteamIdCombo(client)
	local result = string.format("%s (%s)", TGNS.GetClientName(client), TGNS.GetClientSteamId(client))
	return result	
end

function TGNS.GetIsClientVirtual(client)
	local result = client:GetIsVirtual()
	return result
end

function TGNS.SendChatMessage(player, chatMessage, prefix)
	if player ~= nil then
		if prefix == nil or prefix == "" then
			prefix = "PM - " .. DAK.config.language.MessageSender
		end
		chatMessage = string.sub(chatMessage, 1, kMaxChatLength)
		if not TGNS.ClientAction(player, TGNS.GetIsClientVirtual) then
			Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, prefix, -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
		end
	end
end

function TGNS.SendAdminChat(chatMessage, prefix)
	TGNS.DoFor(TGNS.GetMatchingClients(TGNS.GetPlayerList(), TGNS.IsClientAdmin), function(c)
			TGNS.PlayerAction(c, function(p) TGNS.SendChatMessage(p, chatMessage, prefix) end)
		end
	)
end

function TGNS.SendAllChat(chatMessage, prefix)
	TGNS.DoFor(TGNS.GetPlayerList(), function(p)
		TGNS.SendChatMessage(p, chatMessage, prefix)
	end)
end

function TGNS.SendTeamChat(teamNumber, chatMessage, prefix)
	TGNS.DoFor(TGNS.GetTeamClients(teamNumber, TGNS.GetPlayerList()), function(c)
			TGNS.PlayerAction(c, function(p) TGNS.SendChatMessage(p, chatMessage, prefix) end)
		end
	)
end

function TGNS.SendAdminConsoles(message, prefix)
	TGNS.DoFor(TGNS.GetMatchingClients(TGNS.GetPlayerList(), TGNS.IsClientAdmin), function(c)
			TGNS.ConsolePrint(c, message, prefix)
		end
	)
end

function TGNS.DisconnectClient(client, reason)
	pcall(function()
		client.disconnectreason = reason
		Server.DisconnectClient(client)
	end)
end

function TGNS.SortAscending(elements, sortFunction)
	sortFunction = sortFunction or function(x) return x end
	table.sort(elements, function(e1, e2)
		return sortFunction(e1) < sortFunction(e2)
	end)
end

function TGNS.GetFirst(elements)
	local result = elements[1]
	return result
end

function TGNS.ElementIsFoundBeforeIndex(elements, element, index)
	local result = false
	for i = 1, #elements do 
		if i <= index and elements[i] == element then
			result = true
			break
		end
	end
	return result
end

function TGNS.GetPlayerList()

	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	table.sort(playerList, function(p1, p2) 
		return (p1 == nil and "" or p1:GetName()) < (p2 == nil and "" or p2:GetName())
	end)
	return playerList

end

function TGNS.GetPlayerCount() 
	local result = #TGNS.GetPlayerList()
	return result
end

function TGNS.AllPlayers(doThis)

	return function(client)
	
		local playerList = TGNS.GetPlayerList()
		for p = 1, #playerList do
		
			local player = playerList[p]
			doThis(player, client, p)
			
		end
		
	end
	
end

function TGNS.Has(elements, element)
	local found = false
	for i = 1, #elements, 1 do
		if not found and elements[i] == element then
			found = true
		end
	end
	return found
end

function TGNS.GetClient(player)
	local result = Server.GetOwner(player)
	return result
end

function TGNS.GetPlayer(client)
	local result = client:GetControllingPlayer()
	return result
end

function TGNS.GetPlayers(clients)
	local result = {}
	for i = 1, #clients, 1 do
		table.insert(result, TGNS.GetPlayer(clients[i]))
	end
	return result
end

function TGNS.GetClients(players)
	local result = {}
	for i = 1, #players, 1 do
		table.insert(result, TGNS.GetClient(players[i]))
	end
	return result
end

function TGNS.GetMatchingClients(playerList, predicate)
	local result = {}
	playerList = playerList == nil and TGNS.GetPlayerList() or playerList
	for r = #playerList, 1, -1 do
		if playerList[r] ~= nil then
			local client = playerList[r]:GetClient()
			if client ~= nil then
				if predicate(client, playerList[r]) then
					table.insert(result, client)
				end
			end
		end
	end
	return result
end

function TGNS.GetPlayingClients(playerList)
	local result = TGNS.GetMatchingClients(playerList, function(c,p) return TGNS.IsGameplayTeam(p:GetTeamNumber()) end)
	return result
end

function TGNS.GetLastMatchingClient(playerList, predicate)
	local result = nil
	local playerList = playerList == nil and TGNS.GetPlayerList() or playerList
	for r = #playerList, 1, -1 do
		if playerList[r] ~= nil then
			local client = playerList[r]:GetClient()
			if client ~= nil then
				if predicate(client, playerList[r]) then
					result = client
				end
			end
		end
	end
	return result
end

function TGNS.UpdateAllScoreboards()
	TGNS.DoFor(TGNS.GetPlayerList(), function(p)
		p:SetScoreboardChanged(true)
	end)
end

function TGNS.GetTeamClients(teamNumber, playerList)
	local predicate = function(client, player) return player:GetTeamNumber() == teamNumber end
	local result = TGNS.GetMatchingClients(playerList, predicate)
	return result
end

function TGNS.GetSpectatorClients(playerList)
	local predicate = function(client, player) return TGNS.IsPlayerSpectator(player) end
	local result = TGNS.GetMatchingClients(playerList, predicate)
	return result
end

function TGNS.GetMarineClients(playerList)
	local result = TGNS.GetTeamClients(kMarineTeamType, playerList)
	return result
end

function TGNS.GetReadyRoomClients(playerList)
	local result = TGNS.GetTeamClients(kTeamReadyRoom, playerList)
	return result
end

function TGNS.GetAlienClients(playerList)
	local result = TGNS.GetTeamClients(kAlienTeamType, playerList)
	return result
end

function TGNS.GetReadyRoomPlayers(playerList)
	local result = TGNS.GetPlayers(TGNS.GetReadyRoomClients(playerList))
	return result
end

function TGNS.GetMarinePlayers(playerList)
	local result = TGNS.GetPlayers(TGNS.GetMarineClients(playerList))
	return result
end

function TGNS.GetAlienPlayers(playerList)
	local result = TGNS.GetPlayers(TGNS.GetAlienClients(playerList))
	return result
end

function TGNS.GetStrangersClients(playerList)
	local predicate = function(client, player) return TGNS.IsClientStranger(client) end
	local result = TGNS.GetMatchingClients(playerList, predicate)
	return result
end

function TGNS.IsPrimerOnlyClient(client)
	local result = TGNS.HasClientSignedPrimer(client) and not TGNS.IsClientSM(client)
	return result
end

function TGNS.GetPrimerOnlyClients(playerList)
	local predicate = function(client, player) return TGNS.IsPrimerOnlyClient(client) end
	local result = TGNS.GetMatchingClients(playerList, predicate)
	return result
end

function TGNS.GetSmClients(playerList)
	local predicate = function(client, player) return TGNS.IsClientSM(client) end
	local result = TGNS.GetMatchingClients(playerList, predicate)
	return result
end

function TGNS.GetSumUpTo(operand1, operand2, sumLimit)
	local sum = operand1 + operand2
	local result = sum <= sumLimit and sum or sumLimit
	return result
end

function TGNS.KickClient(client, disconnectReason, onPreKick)
	// notes to improve as standalone object: send player to readyroom, spam chat with "look to console" message every second for 5 seconds, hide all other players from scoreboard
	if client ~= nil then
		local player = client:GetControllingPlayer()
		if player ~= nil then
			if onPreKick ~= nil then
				onPreKick(client, player)
			end
		end
		TGNS.SendChatMessage(player, "Kicked. See console for details.", "KICK")
		TGNS.ConsolePrint(client, disconnectReason)
		TGNS.ScheduleAction(5, function() TGNS.DisconnectClient(client, disconnectReason) end)
	end
end

function TGNS.KickPlayer(player, disconnectReason, onPreKick)
	if player ~= nil then
		TGNS.KickClient(player:GetClient(), disconnectReason, onPreKick)
	end
end

function TGNS.GetPlayerMatchingName(name, team)

	assert(type(name) == "string")
	
	local nameMatchCount = 0
	local match = nil
	
	local function Matches(player)
		if nameMatchCount == -1 then
			return // exact match found, skip others to avoid further partial matches
		end
		local playerName =  player:GetName()
		if player:GetName() == name then // exact match
			if team == nil or team == -1 or team == player:GetTeamNumber() then
				match = player
				nameMatchCount = -1
			end
		else
			local index = string.find(string.lower(playerName), string.lower(name)) // case insensitive partial match
			if index ~= nil then
				if team == nil or team == -1 or team == player:GetTeamNumber() then
					match = player
					nameMatchCount = nameMatchCount + 1
				end
			end
		end
		
	end
	TGNS.AllPlayers(Matches)()
	
	if nameMatchCount > 1 then
		match = nil // if partial match is not unique, clear the match
	end
	
	return match

end

function TGNS.GetPlayerMatchingSteamId(steamId, team)

	assert(type(steamId) == "number")
	
	local match = nil
	
	local function Matches(player)
	
		local playerClient = Server.GetOwner(player)
		if playerClient and playerClient:GetUserId() == steamId then
			if team == nil or team == -1 or team == player:GetTeamNumber() then
				match = player
			end
		end
		
	end
	TGNS.AllPlayers(Matches)()
	
	return match

end

function TGNS.GetPlayerMatching(id, team)

	local idNum = tonumber(id)
	if idNum then
		return DAK:GetPlayerMatchingGameId(idNum, team) or TGNS.GetPlayerMatchingSteamId(idNum, team)
	elseif type(id) == "string" then
		return TGNS.GetPlayerMatchingName(id, team)
	end

end

if DAK.config and DAK.config.loader then

	// Returns:	builtChatMessage - a ChatMessage object
	//			consoleChatMessage - a similarly formed string for printing to the console
	function TGNS.BuildPMChatMessage(srcClient, message, command, showCommand)
		if srcClient then
			local srcPlayer = srcClient:GetControllingPlayer()
			if srcPlayer then
				srcName = srcPlayer:GetName()
			else
				srcName = DAK.config.language.MessageSender
			end
		else
			srcName = DAK.config.language.MessageSender
		end

		if showCommand then
			chatName =  command .. " - " .. srcName
		else
			chatName = srcName
		end

		consoleChatMessage = chatName ..": " .. message
		builtChatMessage = BuildChatMessage(false, chatName, -1, kTeamReadyRoom, kNeutralTeamType, message)
		return builtChatMessage, consoleChatMessage
	end
	
	function TGNS.PMAllPlayersWithAccess(srcClient, message, command, showCommand, selfIfNoAccess)
		builtChatMessage, consoleChatMessage = TGNS.BuildPMChatMessage(srcClient, message, command, showCommand)
		for _, player in pairs(TGNS.GetPlayerList()) do
			local client = Server.GetOwner(player)
			if client ~= nil then
				if TGNS.ClientCanRunCommand(client, command) or (selfIfNoAccess and client == srcClient) then
					Server.SendNetworkMessage(player, "Chat", builtChatMessage, true)
					ServerAdminPrint(client, consoleChatMessage)
				end
			end
		end
	end
end

////////////////////////////////
// Intercept Network Messages //
////////////////////////////////

kTGNSNetworkMessageHooks = {}

function TGNS.RegisterNetworkMessageHook(messageName, func, priority)
	local eventName = "kTGNSOn" .. messageName
	TGNS.RegisterEventHook(eventName , func, priority)
end

local originalOnNetworkMessage = {}

local function onNetworkMessage(messageName, ...)
	local eventName = "kTGNSOn" .. messageName
	if not DAK:ExecuteEventHooks(eventName, ...) then
		originalOnNetworkMessage[messageName](...)
	end
end

local originalHookNetworkMessage = Server.HookNetworkMessage

Server.HookNetworkMessage = function(messageName, callback)

	Print("TGNS Hooking: %s", messageName)
	originalOnNetworkMessage[messageName] = callback
	callback = function(...) onNetworkMessage(messageName, ...) end
	kTGNSNetworkMessageHooks[messageName] = callback

	originalHookNetworkMessage(messageName, callback)

end