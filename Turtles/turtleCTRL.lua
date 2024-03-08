require "math"

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
function Pathfind(origin,target)
	result = {}
	
	function turn()
		table.insert(result,1)
	end
	function go()
		table.insert(result,0)
	end
	function stop()
		for i=1,4 do
			table.insert(result,1)
		end
	end
	function turnaround()
		turn()
		turn()
	end
	function turnLeft()
		turnaround()
		turn()
	end
-- Movement Generation
	local facingEast = true
	function X()
		if(target[1]>origin[1]) then -- +X
			for i=1,target[1]-origin[1] do go() end
		else                         -- -X
			turnaround()
			for i=1,origin[1]-target[1] do go() end
			facingEast = false
		end
	end
	if(target[1]-origin[1]~=0) then X() end
	
	function Z()
		if(target[3]>origin[3]) then -- +Y
			if(facingEast) then turn() 
			else turnLeft() end
			for i=1,target[3]-origin[3] do go() end
		else                         -- -Y
			if(facingEast) then turnLeft()
			else turn() end
			for i=1,origin[3]-target[3] do go() end
		end
	end
	if(target[3]-origin[3]~=0) then Z() end
	stop()
	
	return result
end
function send(side,delay,path)
	print("transmission started")
	pulse(side,0.1)
	sleep(delay)
	TableOutput(path)
	for i=1,#path do
		if(path[i]==1) 
		then 
			io.write(1)
			pulse(side,0.25)
		else 
			io.write(0)
			sleep(0.25)
		end
	end
end
function XYZentry()
	XYZ = {"X","Y","Z"}
	result = {}
	for i=1,3 do
		io.write(XYZ[i]," coordinate... -> ")
		coord = assert(tonumber(io.read()),"inexistant coordinate!")
		table.insert(result,coord)
	end
	return result
end
function RESET()
	sides = {"front","back","left","right","top","bottom"}
	for i=1,6 do rs.setOutput(sides[i],false) end
end
io.write("Ready? ")
if(io.read()==r) then RESET() end
function setup()
	io.write("turtle ")
	origin = XYZentry()
	local sides = {"right","left","top","bottom","back","front"}
	io.write("side of modem? (1=right,2=left,3=top,4=bottom,5=back,6=front) -> ")
	side = assert(tonumber(io.read()),"side does not exist!")
	side = sides[side]
	io.write("modem channel? ->")
	delay = assert(tonumber(io.read()),"channel does not exist!")
end
origin = {-234,70,257}
side = "left"
delay = 2
--setup()
while true do
	io.write("target ")
	target = XYZentry()
	path = Pathfind(origin,target)
	time1 = os.clock()
	send(side,delay,path)
	time2 = os.clock()
	io.write("\rtransmission successful! (",time2-time1,"s)\n\n")
end
