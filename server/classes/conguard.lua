ConGuard = inherit(Class)

-- *********************************************

function ConGuard:constructor(dimension, settings)
    if (ConGuardInstances[dimension]) then
        ConGuardInstances[dimension]:delete()
        ConGuardInstances[dimension] = nil
    end

    self.enabled = true
    self.dimension = dimension

    self.settings = deepcopy(DEFAULT_SETTINGS)

    if (settings and type(settings) == "table") then
        for setting, value in pairs(settings) do
            self:setSetting(setting, value)
        end
    end

    self.interruptedPlayers = {}
    self.timeoutListeners = {}
    self.interruptionHistory = {}

    self.queuedPlayers = {}

    self:registerEvent("onPlayerNetworkStatus", root, bind(self.onPlayerNetworkStatus, self))

    ConGuardInstances[dimension] = self
    iprintd("[ConGuard] Created instance in dimension " .. dimension)

    triggerClientEvent(READY_PLAYERS, "onConGuardCreated", resourceRoot, dimension, self.settings)

    for i, player in ipairs(getElementsByType("player")) do
        if (not isPlayerReady(player)) then
            self.queuedPlayers[player] = true
        end
    end

    self.syncQueuedPlayersTimer = setTimer(bind(self.syncQueuedPlayers, self), 100, 0)

    return self
end

function ConGuard:destructor()
    ConGuardInstances[self.dimension] = nil
    iprintd("[ConGuard] Destroyed instance in dimension " .. self.dimension)

    triggerClientEvent(READY_PLAYERS, "onConGuardDestroyed", resourceRoot, self.dimension)
end

-- *********************************************

function ConGuard:syncQueuedPlayers()
    local players = {}
    local remainingPlayers = 0

    for player in pairs(self.queuedPlayers) do
        if (isPlayerReady(player)) then
            players[#players + 1] = player
            self.queuedPlayers[player] = nil
        else
            remainingPlayers = remainingPlayers + 1
        end
    end

    if (remainingPlayers == 0) then
        if (self.syncQueuedPlayersTimer) and (isTimer(self.syncQueuedPlayersTimer)) then
            killTimer(self.syncQueuedPlayersTimer)
            self.syncQueuedPlayersTimer = nil
        end
    end

    if (#players == 0) then
        return false
    end

    triggerClientEvent(players, "onConGuardCreated", resourceRoot, self.dimension, self.settings)
end

-- *********************************************

function ConGuard:setEnabled(state)
    self.enabled = state and true or false
end

function ConGuard:setSetting(setting, value)
    self.settings[setting] = value

    triggerClientEvent(READY_PLAYERS, "onConGuardSettingChange", resourceRoot, self.dimension, setting, value)

    return true
end

function ConGuard:getSetting(setting)
    return self.settings[setting]
end

-- *********************************************

function ConGuard:onPlayerNetworkStatus(status, ticks)
    if (not self.enabled) then
        return false
    end

    local sourcePlayer = source
    local sourceDimension = getElementDimension(sourcePlayer)

    -- check if we're the correct dimension to handle this
    if (self.dimension ~= -1) and (self.dimension ~= sourceDimension) then
        return false
    end

    -- per-dimension instances override a global instance (-1)
    if (self.dimension == -1) and (ConGuardInstances[sourceDimension]) then
        return false
    end

    local broadcastTo = {}

    for i, player in ipairs(getElementsByType("player")) do
        if (getElementDimension(player) == sourceDimension) and (isPlayerReady(player)) then
            broadcastTo[#broadcastTo + 1] = player
        end
    end

    -- connection restored
    if (status == 1) then
        if (not self.interruptedPlayers[sourcePlayer]) then
            return false
        end

        -- Interruption is ending
        iprintd("[ConGuard]", sourcePlayer, "network connection restored")

        if (isTimer(self.timeoutListeners[sourcePlayer])) then
            killTimer(self.timeoutListeners[sourcePlayer])
        end

        self.timeoutListeners[sourcePlayer] = nil

        triggerClientEvent(broadcastTo, "onClientPlayerConnectionStatus", resourceRoot, sourcePlayer, status, nil)
    end

    -- connection interrupted
    if (status == 0) then
        iprintd("[ConGuard]", sourcePlayer, "network connection lost")

        self.interruptionHistory[sourcePlayer] =
            self.interruptionHistory[sourcePlayer] and (self.interruptionHistory[sourcePlayer] + 1) or 1

        if (self.interruptionHistory[sourcePlayer] == self:getSetting("max_interruptions_per_session")) then
            triggerEvent("onPlayerNetworkInterruptionLimitReached", sourcePlayer)

            if (self:getSetting("kick_on_max_interruptions")) then
                kickPlayer(sourcePlayer, self:getSetting("kick_message"))
            end
        end

        local vehicle = getPedOccupiedVehicle(sourcePlayer)
        local x, y, z = getElementPosition(vehicle and vehicle or sourcePlayer)

        self.interruptedPlayers[sourcePlayer] = {
            vehicle = vehicle,
            originPosition = {
                x = x,
                y = y,
                z = z
            }
        }

        self.timeoutListeners[sourcePlayer] =
            setTimer(triggerEvent, self:getSetting("max_connection_timeout"), 1, "onPlayerNetworkTimeout", sourcePlayer)

        triggerClientEvent(
            broadcastTo,
            "onClientPlayerConnectionStatus",
            resourceRoot,
            sourcePlayer,
            status,
            self.interruptedPlayers[sourcePlayer]
        )
    end
end
