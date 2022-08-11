local streamedInPlayers = {}
local interruptedNetworkPlayers = {}
local connectionImageTexture = false

-- *********************************************

function getActiveConGuardInstance()
    local instance = ConGuardInstances[getElementDimension(localPlayer)]

    if (not instance) then
        instance = ConGuardInstances[-1]

        if (not instance) then
            return false
        end
    end

    return instance
end

-- *********************************************

function setPlayerConnectionStatus(player, state, info)
    local instance = getActiveConGuardInstance()

    if (not instance) then
        return false
    end

    if (type(state) ~= "boolean") then
        state = (state == 0) and true or false
    end

    local localVehicle = getPedOccupiedVehicle(localPlayer)

    if (state) then
        if (instance.settings["disable_collisions"]) then
            if (localVehicle) then
                setElementCollidableWith(localVehicle, info.vehicle and info.vehicle or player, false)
            end

            setElementCollidableWith(localPlayer, info.vehicle and info.vehicle or player, false)

            if (info.vehicle) then
                setElementAlpha(info.vehicle, 100)
            end

            setElementAlpha(player, 100)
        end

        setElementFrozen(info.vehicle and info.vehicle or player, true)
    else
        info = interruptedNetworkPlayers[player]

        if (info) then
            if (instance.settings["restore_position"]) then
                setElementPosition(
                    info.vehicle and info.vehicle or player,
                    info.originPosition.x,
                    info.originPosition.y,
                    info.originPosition.z
                )
            end

            setElementFrozen(info.vehicle and info.vehicle or player, false)

            if (isElement(localVehicle)) then
                setElementCollidableWith(localVehicle, info.vehicle and info.vehicle or player, true)
            end

            setElementCollidableWith(localPlayer, info.vehicle and info.vehicle or player, true)

            if (info.vehicle) then
                setElementAlpha(info.vehicle, 255)
            end

            setElementAlpha(player, 255)
        end
    end

    interruptedNetworkPlayers[player] = state and info or nil
end

-- *********************************************

function renderLostConnectionImages()
    local instance = getActiveConGuardInstance()

    if (not instance) then
        return false
    end

    local image = instance:getSetting("lost_connection_image")

    if (not image) then
        return false
    end

    if (not connectionImageTexture) then
        connectionImageTexture = dxCreateTexture(image.path)
    end

    for player, state in pairs(interruptedNetworkPlayers) do
        if (isElement(player)) then
            if (getElementDimension(localPlayer) == getElementDimension(player)) then
                if (streamedInPlayers[player]) then
                    dxDrawImageOnElement(player, connectionImageTexture, image.max_distance, image.height, image.size)
                end
            end
        else
            interruptedNetworkPlayers[player] = nil
        end
    end
end

-- *********************************************

function registerStreamedInPlayer(player)
    streamedInPlayers[player and player or source] = true
end

function unregisterStreamedInPlayer(player)
    streamedInPlayers[player and player or source] = nil
end

-- *********************************************

function initializeStreamedInPlayers()
    for i, player in ipairs(getElementsByType("player")) do
        if (isElementStreamedIn(player)) then
            streamedInPlayers[player] = true
        end
    end
end
