function dxDrawImageOnElement(element, image, distance, height, width, r, g, b, a)
	local x, y, z = getElementPosition(element)
	local x2, y2, z2 = getElementPosition(localPlayer)
	local distance = distance or 20
	local height = height or 1
	local width = width or 1
	local checkBuildings = checkBuildings or true
	local checkVehicles = checkVehicles or false
	local checkPeds = checkPeds or false
	local checkObjects = checkObjects or true
	local checkDummies = checkDummies or true
	local seeThroughStuff = seeThroughStuff or false
	local ignoreSomeObjectsForCamera = ignoreSomeObjectsForCamera or false
	local ignoredElement = ignoredElement or nil
	
	if (isLineOfSightClear(x, y, z, x2, y2, z2, checkBuildings, checkVehicles, checkPeds, checkObjects, checkDummies, seeThroughStuff, ignoreSomeObjectsForCamera, ignoredElement)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z + height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawMaterialLine3D(x, y, z+1+height-(distanceBetweenPoints/distance), x, y, z+height, image, width-(distanceBetweenPoints/distance), tocolor(r or 255, g or 255, b or 255, a or 255))
			end
		end
	end
end
