DEFAULT_SETTINGS = nil

ConGuardInstances = {}

function init()	
	registerEvents()
	importDefaultSettings()
	
	iprintd("[ConGuard] Launched successfully...")
end
addEventHandler("onResourceStart", resourceRoot, init)

function importDefaultSettings()
	local settingsFile = fileOpen("settings.json")
	
	if(settingsFile) then
		local size = fileGetSize(settingsFile)
		local data = fileRead(settingsFile, size)
		
		local convertedJSON = fromJSON(data)
		
		if(convertedJSON) and (type(convertedJSON) == "table") then
			DEFAULT_SETTINGS = convertedJSON
		else
			return error("[ConGuard] Unable to read \"settings.json\" - broken JSON")
		end
		
		fileClose(settingsFile)
	else
		return error("[ConGuard] Unable to open \"settings.json\" - does the file exist?")
	end
end

function registerEvents()
	addEvent("onPlayerNetworkTimeout", true)
	addEvent("onPlayerNetworkInterruptionLimitReached", true)
end

function removePlayerReferences()
	local instance = ConGuardInstances[getElementDimension(source)]
	
	if(not instance) then
		return false
	end
	
	instance:onPlayerNetworkStatus(1)
end
addEventHandler("onPlayerLeave", root, removePlayerReferences)