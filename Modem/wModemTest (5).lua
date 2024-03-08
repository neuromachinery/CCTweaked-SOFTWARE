require "math"
local modem = peripheral.find("modem") or error("No modem attached", 0)

MY_ID = math.random(30)
RECIPIENTS = {MY_ID}

modem.open(MY_ID)
function sleep(delay)
	time = os.clock()
	while os.clock()<time+delay do
		os.sleep(0)
	end
end
function Check(ID)
	if(ID==nil)then return false end
	for i,v in ipairs(RECIPIENTS) do
		if(v==ID)then return true end
	end
	return false
end
function Recieve()
	local event, side, ch, replyChannel, message, distance
	repeat
		event, side, ch, replyChannel, message, distance = os.pullEvent("modem_message")
	until ch == MY_ID
	if(not Check(replyChannel)) then RECIPIENTS[#RECIPIENTS+1]=replyChannel end
	return replyChannel,message
end
function Send(channel,msg)
	modem.transmit(channel,MY_ID,msg)
end


function FWD(reply,channel,msg)
	Send(channel,msg)
end
function BACK(reply,channel,msg)
	MSG = {{"FWD",channel},Exec(msg[1],msg[2])}
	Send(reply,MSG)
end
function PING(reply,channel,msg)
	Send(reply,{{"RESPONSE",MY_ID},{msg,os.clock()}})
end
function PING_RESPONSE(reply,channel,msg)
	print("New one (",reply,")!",msg[2]-msg[1])
end
function NETERROR(reply,channel,msg)
	Send(reply,"ERROR 400")
end
function TERMINATE(...)
	modem.closeAll()
	os.reboot()
end

function LIST(...)
	return RECIPIENTS
end
function Exec(func,...)
	local CMDS = {["LIST"]=LIST}
	return CMDS[func](...)
end
function resolve(reply,msg)
	local CMDS = {["FWD"]=FWD,["BACK"]=BACK,["PING"]=PING,["RESPONSE"]=PING_RESPONSE,["TERMINATE"]=TERMINATE}
	CMDS[msg[1][1]](reply,msg[1][2],msg[2])
end

function discover(channel_limit)
	for i=1,channel_limit do
		Send(i,{{"PING",MY_ID},os.clock()})
	end
end


while(true) do
	resolve(Recieve())	
end