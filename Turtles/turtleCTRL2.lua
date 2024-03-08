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
function Pathfind(origin,target,mode,height)-- Movement Generation
	local result = {}
	
	function add(binary)
		table.insert(result,binary)
	end
	print("PATHFIND:mode:",mode)
	add(mode[1]);add(mode[2]) -- add mode information
	
	if(target[1]<origin[1]) then add(1) else add(0)	end

	if(target[2]<origin[2]) then add(1) else add(0)	end
	
	mode = mode[2]+mode[1]*2
	distances = {4,6,8,16}
	
	distanceX = DecToBinM(math.abs(target[1]-origin[1]),distances[mode+1])
	io.write("X:",target[1]-origin[1],"; ")
	for i=1,distances[mode+1] do add(distanceX[i]) end -- add X
	distanceZ = DecToBinM(math.abs(target[2]-origin[2]),distances[mode+1])
	io.write("Z:",target[2]-origin[2],"\n")
	for i=1,distances[mode+1] do add(distanceZ[i]) end -- add Z
	
	for i=1,#height do add(height[i]) end -- add height
	distX = {"XXXX","XXXXXX","XXXXXXXX","XXXXXXXXXXXXXXXX",}
	distZ = {"ZZZZ","ZZZZZZ","ZZZZZZZZ","ZZZZZZZZZZZZZZZZ",}
	distY = {"YYYY","YY","YY","NO"}
	text = "MMRR"..tostring(distX[mode+1])..tostring(distZ[mode+1])..tostring(distY[mode+1]).."\n"
	return result
end
function send(side,delay,path) -- actual communication
	speed = 0.06
	print("transmission started")
	io.write(text)
	pulse(side,0.1)
	sleep(delay)
	for i=1,#path do
		if(path[i]==1) 
		then 
			io.write(1)
			pulse(side,speed)
		else 
			io.write(0)
			sleep(speed)
		end
	end
end
function XZentry() -- ask for coordinates
	XZ = {"X","Z"}
	result = {}
	for i=1,2 do
		io.write(XZ[i]," coordinate... -> ")
		coord = assert(tonumber(io.read()),"inexistant coordinate!")
		table.insert(result,coord)
	end
	return result
end
function RESET() -- to reset all redstone output in case of crash
	sides = {"front","back","left","right","top","bottom"}
	for i=1,6 do rs.setOutput(sides[i],false) end
end
io.write("Ready? ")
if(io.read()==r) then RESET() end
function setup(origin,side,delay,mode,height) -- configuration
	if(origin==nil)then
		io.write("turtle ")
		origin = XZentry()
	end
	if(side==nil)then
		local sides = {"right","left","top","bottom","back","front"}
		io.write("side of modem? (1=right,2=left,3=top,4=bottom,5=back,6=front) -> ")
		side = assert(tonumber(io.read()),"side does not exist!")
		side = sides[side]
	end
	if(delay==nil)then
		io.write("modem channel? ->")
		delay = assert(tonumber(io.read()),"channel does not exist!")
	end
	if(mode==nil)then
		io.write("turtle range? (0-32x32,1-256x256,2-512x512,3-113Kx113K)->")
		mode = assert(tonumber(io.read()),"mode does not exist!")
	end
	if(height==nil)then
		if(mode~=3) then
			heights = {"0-16","1-4;2-8;3-16;4-32","1-8;2-32;3-64;4-128"}
			sizes = {4,2,2}
			io.write("turtle flight height? (",heights[mode+1],") -> ")
			height = assert(DecToBinM(tonumber(io.read()),sizes[mode+1]),"height does not exist!")
		else
			height = {}
		end
	end
	mode = DecToBinM(mode,2)
	return origin,side,delay,mode,height
end

origin = {-234,257}
side = "left"
delay = 0.06
--mode = {0,0}
--height = {0,0,1,0}
while true do
	origin, side, delay, mode, height = setup(origin,side,delay)
	if(origin == nil or side == nil or delay == nil or mode == nil or height == nil) then print("!");io.read() else print(mode) end
	io.write("target ")
	target = XZentry()
	path = Pathfind(origin,target,mode,height)
	time1 = os.clock()
	send(side,delay,path)
	time2 = os.clock()
	io.write("\ntransmission successful! (",tonumber(string.format("%.2f", time2-time1)),"s)\n\n")
end
