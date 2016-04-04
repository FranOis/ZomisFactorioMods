require "defines"

function distance(position1, position2)
	return ((position1.x - position2.x)^2 + (position1.y - position2.y)^2)^0.5
end

script.on_init(function()
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

script.on_event(defines.events.on_resource_depleted, function(event)
	local resource = event.entity
    for _, player in ipairs(game.players) do
        -- player.print("Depleted resource " .. resource.name .. " at " .. resource.position.x .. ", " .. resource.position.y)
		local drills = findMiningDrillsFor(resource)
		for i, drill in pairs(drills) do
			local resources = findResourcesFor(drill)
			if resources == 0 then
				player.print("Useless Drill " .. drill.name .. " at " .. drill.position.x .. ", " .. drill.position.y .. " used to mine " .. resource.name)
			end
		end
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	local playerIndex = event.player_index
	game.players[playerIndex].print("Clicked " .. element.name)
	if element.name == "empty_drills" then
		-- loop through map and scan for empty drills
		
	end
end)

function initPlayers()
    for _, player in ipairs(game.players) do
        initPlayer(player)
    end
end

function playerCreated(event)
    local player = game.players[event.player_index]
    initPlayer(player)
end

function initPlayer(player)
    if not player.gui.top["empty_drills"] then
		player.gui.left.add{ type = "button", name = "empty_drills", caption = "Drills" }
    end
end

function findMiningDrillsFor(resource)
	local pos = resource.position
	local range = 5
	local surface = game.get_surface(1)
	local drills = surface.find_entities_filtered{area = {{pos.x - range, pos.y - range}, {pos.x + range, pos.y + range}}, type = "mining-drill" }
	
	local result = {}
	
	for _, drill in pairs(drills) do
		local drillRange = getDrillRange(drill)
		if isInDrillRange(drill, resource) then
			table.insert(result, drill)
		end
	end
	
    return result
end

function getDrillRange(drill)
	-- drill resource_searching_radius is defined in data, but not yet accessible through this script
	if drill.name == "burner-mining-drill" then
		return 0.99
	end
	if drill.name == "basic-mining-drill" then
		return 2.49
	end
	return 1
end

function isInDrillRange(drill, resource)
	local range = getDrillRange(drill)
	return distance(drill.position, resource.position) <= range
end

function findResourcesFor(drill)
	local pos = drill.position
	local range = getDrillRange(drill)
	local surface = game.get_surface(1)
	local resources = surface.find_entities_filtered({area = {{pos.x - range, pos.y - range}, {pos.x + range, pos.y + range}}, type = "resource" })
	local sum = 0
	for i, resource in pairs(resources) do
		sum = sum + resource.amount
	end
	return sum
end











