function sleep(delay)
	time = os.clock()
	while os.clock()<time+delay do
		os.sleep(0)
	end
end
function change(side)
	rs.setOutput(side,not rs.getOutput(side))
end
function pulse(side,delay)
	change(side)
	sleep(delay)
	change(side)
end
function DecToBin(Dec)
	result = {}
	while Dec>0 do
		table.insert(result,Dec%2)
		Dec = math.floor(Dec/2)
	end
	return result
end
function TableOutput(Table)
	print(table.concat(Table))
end

turns = 0

function go()
	if(not turtle.forward()) then
		while true do
			if(not turtle.forward() and not turtle.dig()) then
			
				return false
			else
				if(turtle.forward()) then 
					return true 
				end
			end
		end
	end
	return true
end
function turn()
	turtle.turnRight()
end
function Return(missionState)
	function GO(distance)
		for i=distance,1,-1 do -- since it's in Return function, the for loop is backwards
			if (not go()) then 
				os.shutdown()
			end
		end
	end
	turn()
	turn()
	
	GO(missionState[2])
	if(missionState[1]==1) then 
		orientation = table.concat({table.unpack(program,3,4)})
		if(orientation == "00" or orientation == "10") then
			turtle.turnLeft()
		else
			turtle.turnRight()
		end
		GO(X)
	end
	if(program[3]==0) then
		turn()
		turn()
	end
	if(missionState[1]==1 and missionState[2]==Z) then print("mission successful!")
	else print("mission failed!")
	end
	Returned = true
end
function sky(mode)
	chunkY = {table.unpack(program,#program-3,#program)}
	local function S()
		return chunkY[4]+chunkY[3]*2+chunkY[2]*4+chunkY[1]*8
	end
	local function M()
		heights = {4,8,16,32}
		Y = chunkY[4]+chunkY[3]*2
		return heights[Y]
	end
	local function L()
		heights = {8,32,64,128}
		Y = chunkY[4]+chunkY[3]*2
		return heights[Y]
	end
	local function X()
		return 256
	end
	functions = {S,M,L,X}
	local Y = functions[mode+1]()
	
	for i=1,Y do 
		turtle.up()
	end
end
function earth()
	while true do
		if(not turtle.down()) then break end
	end
end
function fixFacing(direction)
	for i=1,direction-1 do
		turn()
	end
end

function listen(side)
	delay = 0.06
	local result = {}
	for i=1,4 do
		if(rs.getInput(side)) then 
			table.insert(result,1)		
		else 
			table.insert(result,0)
		end
		sleep(delay)
	end
	modes = {12,14,18,32}
	for i=1,modes[tonumber(table.concat({table.unpack(result,1,2)}),2)+1] do
		if(rs.getInput(side)) then 
			table.insert(result,1)		
		else 
			table.insert(result,0)
		end
		sleep(delay)
	end
	return result
end

local level = turtle.getFuelLevel()
function refuel()
	io.write ("Refuelling. ")
	result,reason = turtle.refuel()
	if(not result) then io.write("Did not refueled because -> ",reason) end
	return result
end
function checkLevel()
	if(level/turtle.getFuelLimit()>0.25) then
		io.write("Enough fuel")
		result = true
	else
		io.write("Low on fuel. ")
		result = false
	end
	return result
end
local level = turtle.getFuelLevel()
if checkLevel() or refuel() then
else
  print("REFUELLING FAILURE.")
  io.read()
end
function setup()
	io.write("\nwhat direction turtle is facing?(1=east,2=north,3=west,4=south)-> ")
	fixFacing(assert(tonumber(io.read()),"direction does not exist!"))
	io.write("side of modem?(1=right,2=left,3=top,4=bottom,5=back,6=front)-> ")
	side = assert(tonumber(io.read()),"side does not exist!")
	local sides = {"right","left","top","bottom","back","front"}
	side = sides[side]
	io.write("modem channel... ->")
	delay = assert(tonumber(io.read()),"channel does not exist!")
end
side = "right"
delay = 0.06
--setup()
while true do
	Returned = false
	repeat
		start = rs.getInput(side)
		os.sleep(0)
	until start
	sleep(delay+0.1)
	print("\ntransmission started.")
	program = listen(side)
	print("executing program.")
	mode = program[2]+program[1]*2 -- Get mode
	modes = {4,6,8,16}
	mode = modes[mode+1]
	if(program[3]==1) then  -- Get X rotation
		turn()
		turn()
	end
	X = tonumber(table.concat({table.unpack(program,5,4+mode)}),2) -- Get X distance
	Z = tonumber(table.concat({table.unpack(program,5+mode,4+(2*mode))}),2) -- Get Z distance
	sky(program[1]+program[2]*2) -- Ascend for less obstructions
	for i=1,X do -- go along X direction
		if not go() 
		then 
			Return({0,i-1}) 
			break
		end
	end
	if(not Returned) then 
		if(program[4]==1) then -- Get Z rotation
			turtle.turnLeft()
		else
			turn()
		end
		for i=1,Z do -- go along Z direction
			if not go() 
			then 
				Return({1,i-1}) 
				break
			end
		end
		if(not Returned) then 
			earth()
		
			sky(program[1]+program[2]*2) -- Ascend for less obstructions
			Return({1,Z})
			earth()
		end
	end
	earth()
end
