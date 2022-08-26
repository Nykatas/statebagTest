RegisterCommand("spawnTestHorse", function(source, args, rawCommand)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local modelName    = "a_c_horse_gypsycob_splashedpiebald"
	local modelHashKey = GetHashKey(modelName)
	
	RequestModel(modelHashKey)
	while not HasModelLoaded(modelHashKey) do Citizen.Wait(500) end
	
	local myHorse = CreatePed(modelHashKey, playerCoords.x + 2.5, playerCoords.y + 2.5, playerCoords.z + 0.5, 0.0, true, true, 0, 0)
	Citizen.InvokeNative(0x283978A15512B2FE, myHorse, true)  -- _SET_RANDOM_OUTFIT_VARIATION
	Citizen.InvokeNative(0xAEB97D84CDF3C00B, myHorse, false) -- _SET_ANIMAL_IS_WILD
	SetModelAsNoLongerNeeded(modelHashKey)

	Entity(myHorse).state:set('isAHorse', true, true)
end, false)

AddStateBagChangeHandler(nil, nil, function(bagName, key, value, _unused, replicated)
    local entityNet    = tonumber(bagName:gsub('entity:', ''), 10)
    local entity       = NetToEnt(entityNet)
    local entityCoords = GetEntityCoords(entity)
	
	print("BagName: " .. bagName)
	print("Key: " .. key)
	print("Value: " .. tostring(value))
	print("Unused: " .. tostring(_unused))
	print("Replicated: " .. tostring(replicated))
	print("Coords: " .. entityCoords)
end)

RegisterCommand("requestHorseState", function(source, args, rawCommand)
	local closestPed, closestDistance = GetClosestPedInArea(GetEntityCoords(PlayerPedId()), 10.0)

	if Entity(closestPed).state.isAHorse then
		print("Success!")
	else
		print("Failed.")
	end
end, false)

-- | ENTITY FUNCTIONS

function GetClosestPedInArea(coords, maxDistance)
	local playerCoords    = GetEntityCoords(PlayerPedId())
	local closestPedNetId = nil
	local closestDistance = -1

	for _, entity in ipairs(GetPedsInArea(GetEntityCoords(PlayerPedId()), maxDistance)) do
		if DoesEntityExist(entity) then
			if entity ~= PlayerPedId() then
				if closestPed == nil then
					closestPed      = entity
					closestDistance = #(playerCoords - GetEntityCoords(entity))
				else
					local pedDistance = #(playerCoords - GetEntityCoords(entity))
					
					if pedDistance < closestDistance then
						closestPed      = entity
						closestDistance = pedDistance
					end
				end
			end
		end
	end
	
	return closestPed, closestDistance
end

function GetPedsInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetPedGamePool(), false, coords, maxDistance)
end

function GetPedGamePool()
    return GetGamePool('CPed')
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end

    for index, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and index or entity
        end
    end

    return nearbyEntities
end
