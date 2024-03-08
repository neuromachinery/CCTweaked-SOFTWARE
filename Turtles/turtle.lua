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
	turns = turns + 1
end
function Return(missionState)
	local skip = 0
	turn()
	turn()
	for i=missionState-4,1,-1 do
		if(program[i]==0) then 
			if (not go()) then 
				print("!PANIC MODE! AWAITING RESCUE...")
				io.read()
				go()
			end
		else 
			turtle.turnLeft()
		end
	end
	turn()
	turn()
	if(missionState==#program) then print("mission successful!")
	else print("mission failed!")
	end
end
function sky()
	--while true do
	for i=1,10 do
		if(not turtle.up()) then break end
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
	local result = {}
	local stopCounter = 0
	while(stopCounter < 4) do
		if(rs.getInput(side)) then 
			table.insert(result,1)
			stopCounter = stopCounter + 1
		else 
			table.insert(result,0)
			stopCounter = 0
		end
		sleep(0.25)
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
	if(side==6) then print("WARNING! Turtle will break modem!") end
	local sides = {"right","left","top","bottom","back","front"}
	side = sides[side]
	io.write("modem channel... ->")
	delay = assert(tonumber(io.read()),"channel does not exist!")
end
side = "right"
delay = 2
--setup()
while true do
	repeat
		start = rs.getInput(side)
		os.sleep(0)
	until start
	sleep(delay+0.1)
	print("transmission started.")
	program = listen(side)
	print("executing program.")
	sky()
	for i=1,#program-4 do
		if(program[i]==0) then
			if(not go()) then
				Return(i-1)
			end
		else
			turn()
		end
	end
	earth()
	io.read()
	sky()
	Return(#program)
	earth()
end
