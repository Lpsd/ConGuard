DEFAULT_SETTINGS = nil
READY_PLAYERS = {}

function importDefaultSettings()
	local settingsFile = fileOpen("settings.json")
	
	if (settingsFile) then
		local size = fileGetSize(settingsFile)
		local data = fileRead(settingsFile, size)
		
		local convertedJSON = fromJSON(data)
		
		if (convertedJSON) and (type(convertedJSON) == "table") then
			DEFAULT_SETTINGS = convertedJSON
		else
			return error("[ConGuard] Unable to read \"settings.json\" - broken JSON")
		end
		
		fileClose(settingsFile)
	else
		return error("[ConGuard] Unable to open \"settings.json\" - does the file exist?")
	end

    return true
end

function syncAll(player)
    player = player or source

    if (not isElement(player)) or (getElementType(player) ~= "player") then
        return false
    end

    local items = {}

    for dimension, instance in pairs(ConGuardInstances) do
        if (instance) and (instanceof(instance, Class, true)) then
            items[#items+1] = {
                dimension = dimension,
                settings = instance.settings
            }    
        end
    end

    triggerClientEvent(player, "onConGuardSyncAll", resourceRoot, items)
end

function isPlayerReady(player)
    for i, p in ipairs(READY_PLAYERS) do
        if (p == player) then
            return true
        end
    end

    return false
end

function addPlayer(player)
    table.insert(READY_PLAYERS, player)
    syncAll(player)
end

function removePlayer()
	local instance = ConGuardInstances[getElementDimension(source)]
	
	if (not instance) then
		return false
	end
	
	instance:onPlayerNetworkStatus(1)

    for i, player in ipairs(READY_PLAYERS) do
        if (player == source) then
            table.remove(READY_PLAYERS, i)
            break
        end
    end
end