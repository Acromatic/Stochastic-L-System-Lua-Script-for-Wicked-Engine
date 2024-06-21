-- This script is a Stochastic L-system for the wicked engine - it grows trees and lightening
killProcesses()  -- stops all running lua coroutine processes

backlog_post("---> START SCRIPT: lsystem.lua")

-- Koch Curve Rule Set for Stochastic L-system Fractiles in python - The 2D Algea Algorithm
--
-- AXIOM = 'A'
-- RULES = { 'A' : 'B',
--           'B' : 'BA'}
-- ITERATIONS = 6
-- def lsystem(start, rules):
--    out = ''
--    for c in start:
--        s = rules[c]
--        out += s
--    return out
-- s = AXIOM
-- print(s)
-- for i in range(ITERATIONS):
--     s = lsystem(s, RULES)
--     print(s)
--
-- Koch Curve Rules     -F becomes F+F-F-F+F     + becomes +    - becomes -
-- Snow Flake Rules      F becomes F+F--F+F      + becomes +    - becomes -
---------------------------------------------------------------------------------


-- Implimentation of Models for the Stochastic L-system
scene = GetScene()
scene.Clear()
model_entity = LoadModel(script_dir() .. "assets/lsystem.wiscene")
transform_component = scene.Component_GetTransform(model_entity)

cube_entity = scene.Entity_FindByName("cube")  -- query the cube entity by name
sphere_entity = scene.Entity_FindByName("sphere")  -- query the sphere entity by name
cube_transform_component = scene.Component_GetTransform(cube_entity)
sphere_transform_component = scene.Component_GetTransform(sphere_entity)

runProcess(function()

    -- Define the L-system rules
    local rules = {
		A = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
        B = "FF[+F+F]",
		C = "FFFF[+F+F][+F+F][+F+F]",
        D = "AA[+F+F][+F+F]FF[+F+F]",
		E = "F+F-F-F+F",
		F = "F+F--F+F",
		G = "",
		H = "",
		I = "",
		J = "",
		K = ""
    }

    -- Generate the L-system string
    local function generate(axiom, iterations)
        local current = axiom
        for i = 1, iterations do
            local next = ""
            for c in current:gmatch(".") do
                next = next .. (rules[c] or c)
            end
            current = next
        end
		
        return current
    end

	-- Rotate a vector by an angle around the X axis
	local function rotate(vec, angleX, angleY, angleZ)
		local cosAngle = math.cos(angleX)
		local sinAngle = math.sin(angleX)
		vec = Vector(vec.X, cosAngle * vec.Y - sinAngle * vec.Z, sinAngle * vec.Y + cosAngle * vec.Z)
		
		cosAngle = math.cos(angleY)
		sinAngle = math.sin(angleY)
		vec = Vector(cosAngle * vec.X + sinAngle * vec.Z, vec.Y, -sinAngle * vec.X + cosAngle * vec.Z)
		
		cosAngle = math.cos(angleZ)
		sinAngle = math.sin(angleZ)
		vec = Vector(cosAngle * vec.X - sinAngle * vec.Y, sinAngle * vec.X + cosAngle * vec.Y, vec.Z)
		
		return vec
	end

	-- Create a turtle
	local turtle = {pos = Vector(0,0,0), dir = Vector(0,1,0)}

	-- Interpret the L-system string as drawing commands
	local function draw(plant, turtle, angle, t)

		local bundle = {}  -- Store the start and end positions of all the ("bundles of") sticks here
		local recall = {}  -- Store the save and restore positions in the recall
		local startcolor = Vector(1,0,1,0.5)  -- pink, but zero intensity emissive
		local endcolor = Vector(1,0,1,0)  -- 2x intensity pink emissive
		for c in plant:gmatch(".") do

			if c == 'F' then
				-- Move forward and store the line
				local newPos = Vector(turtle.pos.X + turtle.dir.X, turtle.pos.Y + turtle.dir.Y, turtle.pos.Z + turtle.dir.Z)
				local color = vector.Lerp(startcolor, endcolor, math.sin(t) * 0.5 + 0.5)

				-- Store it in the bundle
				table.insert(bundle, {startPos = turtle.pos, endPos = newPos, color = color}) 
				turtle.pos = newPos

				--sphere_entity
				cube_transform_component.SetPosition(newPos)



			elseif c == '+' then
				-- Rotate Branch Randomly along X and Z
				local randomAngleX = math.random() * 2 * math.pi
				local randomAngleZ = math.random() * 2 * math.pi
				turtle.dir = rotate(turtle.dir, randomAngleX, angle, randomAngleZ)

				--apply cube_entity rotations
				cube_transform_component.SetRotation(turtle.dir)


			elseif c == '-' then
				-- Rotate Branch Fixed Position along X and Z
				turtle.dir = rotate(turtle.dir, 0, -angle, 0)

			elseif c == '[' then
				-- Save the current state
				table.insert(recall, {pos = Vector(turtle.pos.X, turtle.pos.Y, turtle.pos.Z), dir = Vector(turtle.dir.X, turtle.dir.Y, turtle.dir.Z)})

			elseif c == ']' then
				-- Restore the saved state
				local state = table.remove(recall)
				turtle.pos = state.pos
				turtle.dir = state.dir
			else
				-- Recursively Generate that Item if it exists else quit
				local recurse = generate(c, 1)
				if c == recurse then
					--not a valid rule
				end
			end
		end

		return bundle 
	end

   -- Generate and draw the L-system
	local plant = generate("C", 1)
    local t = 0
	local lines = draw(plant, turtle, math.pi * 2, t)
	while true do
		t = t + 0.1
		for i, line in ipairs(lines) do
			DrawLine(line.startPos, line.endPos, line.color)
		end

		-- Debug the color variable
		DrawDebugText("Stochastic L-system", Vector(-15,2,2), Vector(0,1,0,1), 2, DEBUG_TEXT_CAMERA_FACING | DEBUG_TEXT_CAMERA_SCALING)

		render()
	end
end)

backlog_post("---> END SCRIPT: lsystem.lua")
