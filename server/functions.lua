function cg_call(dimension, method, ...)
	dimension = tonumber(dimension)
	
	if(not ConGuardInstances[dimension]) then
		return false
	end
	
	if(not ConGuardInstances[dimension][method]) then
		return false
	end
	
	return ConGuardInstances[dimension][method](...)
end

-- *********************************************

function createConnectionGuard(dimension, settings)
	dimension = tonumber(dimension)
	
	if(not dimension) then
		return false
	end
	
	if(dimension ~= 1 and ConGuardInstances[-1]) then
		return iprintd("[ConGuard] Can't create a per-dimension instance when a global instance already exists")
	end
	
	if(dimension == -1 and not ConGuardInstances[-1] and #ConGuardInstances > 0) then
		return iprintd("[ConGuard] Can't create a global instance when per-dimension instances already exist.")
	end
	
	local instance = ConGuard:new(dimension, settings)
	
	if(dimension == -1) then
		instance:setSetting("global", true)
	end
	
	return true
end

function destroyConnectionGuard(dimension)
	return cg_call(dimension, "delete")
end

function setConnectionGuardEnabled(dimension, state)
	return cg_call(dimension, "setEnabled", state)
end

function setConnectionGuardSetting(dimension, setting, value)
	return cg_call(dimension, "setSetting", setting, value)
end

function getConnectionGuardSetting(dimension, setting)
	return cg_call(dimension, "getSetting", setting)
end
