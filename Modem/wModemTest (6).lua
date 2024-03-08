require "math"
local modem = peripheral.find("modem") or error("No modem attached", 0)

MY_ID = math.random(99)
NETWORK = {[MY_ID]={MY_ID}}
modem.open(MY_ID)
function sleep(delay)
	time = os.clock()
	while os.clock()<time+delay do
		os.sleep(0)
	end
end
function tableConcat(tab,delim) -- table concatenation
	txt = ""
	if(#tab==1)then return tostring(tab[1]) end
	for i=1,#tab-1 do
		txt = txt..tab[i]..delim
	end
	txt=txt..tab[#tab]
	return txt
end
function Check(ID) -- check if this channel is already known or not
	if(ID==nil)then return false end
	for i,v in ipairs(NETWORK[MY_ID]) do
		if(v==ID)then return true end
	end
	return false
end
function PathResolve(ID)
	for k,v in pairs(NETWORK) do
		for index=1,#v do
			if(v[index]==ID)then return k
		end
	end
end


function Recieve(timeout) -- a bit complicated recieve packet function. Also auto saves any new net addresses.
	if(timeout~=nil)then os.startTimer(timeout)
	Time = os.clock()
	else timeout=-1
	end
	local messages = {}
	local event, side, ch, replyChannel, message, distance
	local function timer() os.pullEvent("timer")end
	local function msg_rcv()
		repeat
			repeat
				event, side, ch, replyChannel, message, distance = os.pullEvent("modem_message")
			until ch == MY_ID
			if(not Check(replyChannel)) then NETWORK[MY_ID][#NETWORK[MY_ID]+1]=replyChannel end
			messages[replyChannel] = message
		until os.clock()>Time+timeout
	end
	parallel.waitForAny(timer,msg_rcv)
	return messages
end
function Send(channel,msg) -- sends message to specified channel and "signed" with your open channel
	modem.transmit(channel,MY_ID,msg)
end
function MakePacket(Type,TypeArg,Msg) -- packet wrapper
	return {{Type,TypeArg},{Msg}}

function FWD(reply,channel,msg) -- re-send this packet to someone else
	Send(channel,msg)
end
function BACK(reply,channel,msg) -- make a ForWarD packet to specified channel with requested info and send it back
	MSG = MakePacket("FWD",channel,Exec(msg[1],msg[2]))
	Send(reply,MSG)
end
function PING(reply,channel,msg) -- ping with time packet was sent
	Send(reply,{{"RESPONSE",MY_ID},{msg,os.clock()}})
end
function PING_RESPONSE(reply,channel,msg) -- display info about the ping
	if(Check(reply))then 
		txt = tableConcat(NETWORK[MY_ID],",")
	else
		txt = " ["..tostring(os.clock()).."] New one ("..tostring(reply)..")! Ping is "..tostring(msg[2]-msg[1])
	end
	term.write(txt)
end
function REC_NETWORK(reply,channel,msg) -- Save recieved list of net addresses
	NETWORK[channel] = msg
end
function TERMINATE(...) -- Shut up and stop using your modem
	modem.closeAll()
	os.reboot()
end
function SEND_NETWORK(reply,channel,msg) -- send all network addresses stored to channel that sent this packet
	Send(reply,{{"RECNET":MY_ID},{NETWORK[MY_ID]}})
end

function LIST(...) -- just get list of net addresses
	return NETWORK[MY_ID]
end
function Exec(func,...) -- reserved for future functions. Just executes whatever internal function specified with args
	local CMDS = {["LIST"]=LIST}
	return CMDS[func](...)
end
function resolve(reply,msg) -- figure out what to do with recieved packet, and then do what was figured out
	local CMDS = {["FWD"]=FWD,["BACK"]=BACK,["PING"]=PING,["RESPONSE"]=PING_RESPONSE,["SENDNET"]=SEND_NETWORK,["RECNET"]=REC_NETWORK,["TERMINATE"]=TERMINATE}
	CMDS[msg[1][1]](reply,msg[1][2],msg[2])
end

function discover(channel_limit) 
	for i=1,channel_limit do -- Send pings to everyone in range
		Send(i,{{"PING",MY_ID},os.clock()})
	end
	messageQueue = Recieve(1) -- Get all responses
	for reply,msg in pairs(messageQueue) do -- process each response
		resolve(reply,msg)
	end
	-- finish discovery algorithm
end

discover(100)
while(true) do
	term.write(" NETWORK[MY_ID]:("..tableConcat(NETWORK[MY_ID],",")..") ["..os.clock().."]")
	
	for recipient=1,#NETWORK[MY_ID] do
		if(NETWORK[MY_ID][recipient]~=MY_ID)then
		MSG = {{"SENDNET",MY_ID},{nil}}
		modem.transmit(NETWORK[MY_ID][recipient],NETWORK[MY_ID][recipient],MSG)
	end end
	term.clearLine()
	x,y = term.getCursorPos()
	term.setCursorPos(0,y)
end
--possibly outdated recieving machines.