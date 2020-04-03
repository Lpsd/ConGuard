ConGuard = {
	connectionImagePath = "assets/images/nosignal.png",
	connectionImageTexture = false,
	streamedInPlayers = {},
	interruptedNetworkPlayers = {}
}

function setPlayerConnectionStatus(state, info, settings)
	if(type(state) ~= "boolean") then
		state = (state == 0) and true or false
	end
	
	local localVehicle = getPedOccupiedVehicle(localPlayer)
	
	if(state) then
		if(settings["disable_collisions"]) then
			if(localVehicle) then
				setElementCollidableWith(localVehicle, info.vehicle and info.vehicle or source, false)
			end
			setElementCollidableWith(localPlayer, info.vehicle and info.vehicle or source, false)
			
			if(info.vehicle) then
				setElementAlpha(info.vehicle, 100)
			end
			
			setElementAlpha(source, 100)
		end	
	
		setElementFrozen(info.vehicle and info.vehicle or source, true)
	else
		info = ConGuard.interruptedNetworkPlayers[source]
		
		if(info) then
			if(settings["restore_position"]) then
				setElementPosition(info.vehicle and info.vehicle or source, info.originPosition.x, info.originPosition.y, info.originPosition.z)
			end
			
			setElementFrozen(info.vehicle and info.vehicle or source, false)
			
			setElementCollidableWith(localVehicle, info.vehicle and info.vehicle or source, true)
			setElementCollidableWith(localPlayer, info.vehicle and info.vehicle or source, true)
			
			if(info.vehicle) then
				setElementAlpha(info.vehicle, 255)
			end
			
			setElementAlpha(source, 255)
		end
	end

	ConGuard.interruptedNetworkPlayers[source] = state and info or nil
	
	iprintd(source, state)
end
addEvent("onClientPlayerConnectionStatus", true)
addEventHandler("onClientPlayerConnectionStatus", root, setPlayerConnectionStatus)

-- *********************************************

function renderLostConnectionImages()
	if(not ConGuard.connectionImageTexture) then
		ConGuard.connectionImageTexture = dxCreateTexture(ConGuard.connectionImagePath)
	end
	
	for player, state in pairs(ConGuard.interruptedNetworkPlayers) do
		if(getElementDimension(localPlayer) == getElementDimension(player)) then
			if(ConGuard.streamedInPlayers[player]) then
				dxDrawImageOnElement(player, ConGuard.connectionImageTexture)
			end
		end
	end
end
addEventHandler("onClientPreRender", root, renderLostConnectionImages)

-- *********************************************

function setCustomConnectionImage(path)
	ConGuard.connectionImagePath = path
end

-- *********************************************

function registerStreamedInPlayer(player)
	ConGuard.streamedInPlayers[player and player or source] = true
end
addEventHandler("onClientElementStreamIn", root, registerStreamedInPlayer)

function unregisterStreamedInPlayer(player)
	ConGuard.streamedInPlayers[player and player or source] = nil
end
addEventHandler("onClientElementStreamOut", root, unregisterStreamedInPlayer)

-- *********************************************
	
function initializeStreamedInPlayers()
	for i, player in ipairs(getElementsByType("player")) do
		if(isElementStreamedIn(player)) then
			ConGuard.streamedInPlayers[player] = true
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, initializeStreamedInPlayers)

-- *********************************************