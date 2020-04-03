ConGuard = {}

function ConGuard:new(...)
	return new(self, ...)
end

function ConGuard:delete(...)
	ConGuardInstances[self.dimension] = nil
	delete(self, ...)
	
	iprintd("[ConGuard] Destroyed instance in dimension " .. dimension)
end

-- *********************************************

function ConGuard:constructor(dimension, settings)
	self.state = true
	self.dimension = dimension
	
	self.settings = DEFAULT_SETTINGS
	
	if(settings and type(settings) == "table") then
		for setting, value in pairs(settings) do
			self:setSetting(setting, value)
		end
	end
	
	self.interruptedPlayers = {}
	self.timeoutListeners = {}
	self.interruptionHistory = {}
	
	self:bindEvents()
	
	ConGuardInstances[self.dimension] = self

	iprintd("[ConGuard] Created instance in dimension " .. dimension)
end

-- *********************************************

function ConGuard:setEnabled(state)
	self.state = state and true or false
end

-- *********************************************

function ConGuard:setSetting(setting, value)
	if(not self.settings[setting]) then
		return false
	end
	
	if(type(value) ~= type(self.settings[setting])) then
		return false
	end
	
	self.settings[setting] = value
	
	return true
end

function ConGuard:getSetting(setting)
	return self.settings[setting]
end

-- *********************************************

function ConGuard:onPlayerNetworkStatus(status, ticks)
	local player = source
	
	local broadcastTo = {}
	
	for i, player in ipairs(getElementsByType("player")) do
		if(getElementDimension(player) == self.dimension) then
			broadcastTo[#broadcastTo+1] = player
		end
	end
	
	if(status == 1) then
		if(not self.interruptedPlayers[player]) then
			return false
		end
		
		-- Interruption is ending
		iprintd(player, "network connection restored")
		
		if(isTimer(self.timeoutListeners[player])) then
			killTimer(self.timeoutListeners[player])
		end
		
		self.timeoutListeners[player] = nil
		
		self.interruptionHistory[player] = self.interruptionHistory[player] and (self.interruptionHistory[player] + 1) or 1
		
		if(self.interruptionHistory[player] == self:getSetting("max_interruptions_per_session")) then
			triggerEvent("onPlayerNetworkInterruptionLimitReached", player)
		end		
		
		triggerClientEvent(broadcastTo, "onClientPlayerConnectionStatus", player, status, nil, self.settings)
		
		return
	end
	
	iprintd(player, "network connection lost")
	
	local vehicle = getPedOccupiedVehicle(player)
	local x, y, z = getElementPosition(vehicle and vehicle or player)
	
	self.interruptedPlayers[player] = {
		vehicle = vehicle,
		originPosition = {
			x = x,
			y = y,
			z = z
		}
	}
	
	self.timeoutListeners[player] = setTimer(triggerEvent, self:getSetting("max_connection_timeout"), 1, "onPlayerNetworkTimeout", player)
	
	triggerClientEvent(broadcastTo, "onClientPlayerConnectionStatus", player, status, self.interruptedPlayers[player], self.settings)
end

-- *********************************************

function ConGuard:bindEvents()
	self.fOnPlayerNetworkStatus = bind(self.onPlayerNetworkStatus, self)
	addEventHandler("onPlayerNetworkStatus", root, self.fOnPlayerNetworkStatus)
end

function ConGuard:unbindEvents()
	removeEventHandler("onPlayerNetworkStatus", root, self.fOnPlayerNetworkStatus)
end

-- *********************************************