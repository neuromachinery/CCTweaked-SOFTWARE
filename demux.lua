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
function change_bundled(side,channels)
	
	for i=0,16 do
		print("duh")
	end
end
function pulse_bundled(side,channels,delay)

end
function DecToBin16bit(Dec)
	result = {}
	for i=1,16 do
		table.insert(result,Dec%2)
		Dec = math.floor(Dec/2)
	end
	return result
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
function func()
	io.write("give a number\n")
	Result = DecToBin16bit(tonumber(io.read()))
	TableOutput(Result)
	io.write("data: ")
	for i=1,8 do
		io.write(Result[i])
	end
	io.write("\nchannel: ")
	for i=9,#Result do
		io.write(Result[i])
	end	
	io.write("\n")
end
function send(channel,word)
	for i=1,#word do

	end
end
function func2()
	while true do
		repeat
			start = rs.getInput("top")
			os.sleep(0.9)
		until start
		print(rs.getBundledInput("left"))
	end
end
func()