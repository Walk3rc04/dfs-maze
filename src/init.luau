-- Maze Generator (DFS backtracker)
-- Freshman project. Controlled via Script attributes (height, width, etc).
-- Generates a wall grid then carves passages with raycasts.

local MAZE_HEIGHT : number = script:GetAttribute("MAZE_HEIGHT") -- Z
local MAZE_WIDTH : number = script:GetAttribute("MAZE_WIDTH") -- X
local CELL_SIZE : number = script:GetAttribute("CELL_SIZE")
local WALL_THICKNESS : number = script:GetAttribute("WALL_THICKNESS")
local WALL_HEIGHT : number = script:GetAttribute("WALL_HEIGHT")
local CLEAR_RANDOM : number = script:GetAttribute("CLEAR_RANDOM")
local CELL_MARKERS : boolean = script:GetAttribute("CELL_MARKERS")

local walls : Folder = Instance.new("Folder", workspace)
walls.Name = "Walls"

local function codeXZ(x, z)
	return tostring(x).."-"..tostring(z)
end
local function decodeXZ(str)
	return string.match(str, "(%d+)-(%d+)")
end

-- Place down all the walls
local function placeWalls()
	for rotation = 0, 90, 90 do
		for x = 1, MAZE_WIDTH + rotation/90 do
			for z = 1, MAZE_HEIGHT + 1 - rotation/90 do
				local wall = Instance.new("Part")
				wall.Name = codeXZ(x, z).."-"..tostring(rotation)
				wall.Anchored = true
				wall.Size = Vector3.new(CELL_SIZE + WALL_THICKNESS, WALL_HEIGHT, WALL_THICKNESS)
				local centerCFrame = CFrame.new(Vector3.new(x * CELL_SIZE, WALL_HEIGHT/2, z * CELL_SIZE))
				wall.CFrame = centerCFrame  * CFrame.new(Vector3.new(-CELL_SIZE/2 * rotation/90, 0, -CELL_SIZE/2 * (1 - rotation/90)))
				wall.Rotation = Vector3.new(0, rotation, 0)
				wall.Parent = walls
			end
		end
	end
end

local markers : Folder = Instance.new("Folder", workspace)
markers.Name = "Markers"

-- Optional visualizer to show center of each cell
local function placeMarkers()
	for x = 1, MAZE_WIDTH do
		for z = 1, MAZE_HEIGHT do
			local marker = Instance.new("Part")
			marker.Size = Vector3.new(1, 1, 1)
			marker.Name = codeXZ(x, z)
			marker.Position = Vector3.new(x * CELL_SIZE, WALL_HEIGHT/2, z * CELL_SIZE)
			marker.Material = Enum.Material.Neon
			marker.Color = Color3.new(0.227451, 1, 0.0117647)
			marker.Anchored = true
			marker.Parent = markers
		end
	end
end


local visited = {}

local function getNextCell(x, z)
	x = tonumber(x)
	z = tonumber(z)
	local neighbors = {}
	-- north (-z)
	if z > 1 and not table.find(visited, tostring(x).."-"..tostring(z-1)) then
		table.insert(neighbors, tostring(x).."-"..tostring(z-1))
	end
	-- south (+z)
	if z < MAZE_HEIGHT and not table.find(visited, tostring(x).."-"..tostring(z+1)) then
		table.insert(neighbors, tostring(x).."-"..tostring(z+1))
	end
	-- east (+x)
	if x < MAZE_WIDTH and not table.find(visited, tostring(x+1).."-"..tostring(z)) then
		table.insert(neighbors, tostring(x+1).."-"..tostring(z))
	end
	-- west (-x)
	if x > 1 and not table.find(visited, tostring(x-1).."-"..tostring(z)) then
		table.insert(neighbors, tostring(x-1).."-"..tostring(z))
	end
	if #neighbors >= 1 then 
		return decodeXZ(neighbors[math.random(1,#neighbors)])
	end
	return nil, nil
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {markers}

local stack = {}
-- use backward recursive to get maze path
-- use path and to remove all unneeded walls
local function createPath()
	local x1 = 1
	local z1 = 1
	local x2
	local z2
	repeat
		if not table.find(visited, codeXZ(x1, z1)) then
			table.insert(visited, codeXZ(x1, z1))
		end
		x2, z2 = getNextCell(x1, z1)
		if x2 == nil then -- did not get valid cell, go back
			--print(stack)
			x1, z1 = decodeXZ(stack[#stack]) -- assigning to previous
			table.remove(stack) -- removes top item
		else -- delete wall between two points
			local pos1 = Vector3.new(x1 * CELL_SIZE, WALL_HEIGHT/2, z1 * CELL_SIZE)
			local pos2 = Vector3.new(x2 * CELL_SIZE, WALL_HEIGHT/2, z2 * CELL_SIZE)
			local rayDir = (pos2 - pos1)
			local wall = workspace:Raycast(pos1, rayDir, rayParams)
			if wall then
				if wall.Instance:IsA("BasePart") then
					wall.Instance:Destroy()
				else
					warn("Hit was not a basepart")
				end
			else
				warn("No ray hit")
			end
			table.insert(stack, codeXZ(x1, z1))
			x1, z1 = x2, z2
		end

	until #visited == MAZE_HEIGHT * MAZE_WIDTH
end

local function updateVariables()
	MAZE_HEIGHT = script:GetAttribute("MAZE_HEIGHT") -- Z
	MAZE_WIDTH = script:GetAttribute("MAZE_WIDTH") -- X
	CELL_SIZE = script:GetAttribute("CELL_SIZE")

	WALL_THICKNESS = script:GetAttribute("WALL_THICKNESS")
	WALL_HEIGHT = script:GetAttribute("WALL_HEIGHT")

	CLEAR_RANDOM = script:GetAttribute("CLEAR_RANDOM")

	CELL_MARKERS = script:GetAttribute("CELL_MARKERS")
end

local function main()
	table.clear(stack)
	table.clear(visited)
	walls:ClearAllChildren()
	updateVariables()
	local t1 = tick()
	if CELL_MARKERS then placeMarkers() end
	placeWalls()
	local t2 = tick()
	print("Time to place markers and walls:",t2 - t1)
	createPath()
	local t3 = tick()
	print("Time to create path:", t3 - t2)
	for i=0, CLEAR_RANDOM-1 do
		local x = math.random(2, MAZE_WIDTH)
		local z = math.random(2, MAZE_HEIGHT)
		local rotation = math.random(0,1)*90
		local wall = walls:FindFirstChild(codeXZ(x,z).."-"..rotation)
		if wall then wall:Destroy() end
	end
	local t4 = tick()
	print("Time to clear:", t4-t3)
	print("=== TOTAL TIME: " .. t4-t1 .. " ===")
end
