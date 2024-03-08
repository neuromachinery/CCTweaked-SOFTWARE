require "math"
gs = peripheral.wrap("right")
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
	--io.write("D")
	change(side)
	sleep(delay)
	change(side)
end
function DecToBinL(Dec,Lenght)
	-- returns a table of bits, least significant first.
	local result = {}
	for i=1,Lenght do
		table.insert(result,Dec%2)
		Dec = math.floor(Dec/2)
	end
	return result
end
function DecToBinM(num,bits) -- I stole this one
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end
function TableOutput(Table)
	print(table.concat(Table))
end
function go(targets)
	while true do if(turtle.forward()) then return true else if(not turtle.dig()) then return false end end end
	return true
end
function Pathfind(target)-- Movement Generation
	if(target[1]<0) then turtle.turnRight();turtle.turnRight(); end
	for i=1,math.abs(target[1]) do
		go(1,X) --not using return value
	end
	if(target[1]<0) then turtle.turnRight();turtle.turnRight() end
	
	if(target[2]<0) then directionY=turtle.down;DigY=turtle.digDown; else directionY=turtle.up;DigY=turtle.digUp end 
	for i=1,math.abs(target[2]) do
		while true do
			if(directionY()) then break
			else if(not DigY()) then end 
			end
		end
	end

	if(target[3]<0) then turtle.turnLeft() else turtle.turnRight() end
	for i=1,math.abs(target[3]) do
		go(3,Z)
	end
	
	if(target[3]<0) then turtle.turnRight() else turtle.turnLeft() end
	

end
function sort(blocks)
	local result = {}
	local distances = {}
	function Sort(a,b)
		if(a[1]<b[1])then return true else return false end
	end
	for i=1,#blocks do
		distances[i] = {math.abs(blocks[i]["x"])+math.abs(blocks[i]["y"])+math.abs(blocks[i]["z"]),i}
	end
	table.sort(distances,Sort)
	for i=1,#distances do
		result[i] = blocks[distances[i][2]]
	end
	return result
end
function addTables(table1,table2)
	if(#table2~=#table1)then return nil end
	local result = {}
	for i=1,#table1 do
		result[i] = table1[i] + table2[i]
	end
	return result
end
function subtractTables(table1,table2)
	if(#table2~=#table1)then return nil end
	local result = {}
	for i=1,#table1 do
		result[i] = table1[i] - table2[i]
	end
	return result
end
function refuel()
		io.write ("Refuelling. ")
		result,reason = turtle.refuel()
		if(not result) then io.write("Did not refueled because -> ",reason,"\n") end
		return result
	end
function checkLevel()
		if(level/turtle.getFuelLimit()>0.25) then
			io.write("Enough fuel\n")
			result = true
		else
			io.write("Low on fuel. ")
			result = false
		end
		return result
	end
function clear()
		for i=2,16 do
			turtle.select(i)
			turtle.dropUp(turtle.getItemCount(i))
		end
		turtle.select(1)
	end
function getNameFromInventorySlot(slot) return turtle.getItemDetail(slot)["name"] end
function full(mode,block)
		result = 0
		for i=2,16 do
			if(turtle.getItemCount(i)==0)then result=result+1 end
		end
		if(result>3)then return false else return true end
	end
function Scan(scanRadius)
	level = turtle.getFuelLevel()
	if checkLevel() or refuel() then
	else
		print("REFUELLING FAILURE.")
		io.read()
		return nil
	end
	done = false
	name = getNameFromInventorySlot(2)
	--name = "minecraft:bricks"
	clear()
	origin = {0,0,0}
	while (not full() and not done) do
	blocks = gs.scan(scanRadius)
	targets = {}
	for i=1,#blocks do 
		if(blocks[i]["name"]==name) then 
			table.insert(targets,blocks[i])
		end
	end
	
	local XYZ = {0,0,0}
	for i=1,#targets do
		--io.write(i,":",targets[i]["x"],";",targets[i]["y"],";",targets[i]["z"],"\n")
		--io.write(i+1,":",targets[i+1]["x"],"-",targets[i]["x"],";",targets[i+1]["y"],"-",targets[i]["y"],";",targets[i+1]["z"],"-",targets[i]["z"],"\n")
		Pathfind({targets[i]["x"],targets[i]["y"],targets[i]["z"],targets})
		for j=i+1,#targets do
			targets[j]["x"]=targets[j]["x"]-targets[i]["x"]
			targets[j]["y"]=targets[j]["y"]-targets[i]["y"]
			targets[j]["z"]=targets[j]["z"]-targets[i]["z"]
		end
		sortTargets = sort({table.unpack(targets,i+1,#targets)})
		targets = {table.unpack(targets,1,i)}
		for i=1,#sortTargets do
			table.insert(targets,sortTargets[i])
		end
		
		XYZ = subtractTables(XYZ,{targets[i]["x"],targets[i]["y"],targets[i]["z"]})
	end
	Pathfind(XYZ)
	--origin[2] = origin[2] + 1 + scanRadius*2
	for i=0,scanRadius*2 do 
		while not done do
			if(turtle.down()) 
			then 
				origin[2]=origin[2] + 1
				break
			else if(not turtle.digDown()) then done=true end 
			end
		end
		if(done)
		then 
			--origin[2]=origin[2]+i-scanRadius*2 -- Fucked up calculations. Fix 'em!
			break  
		end
	end
	end
	Pathfind(origin)
	clear()
end
Scan(5)