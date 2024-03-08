require "math"
local modem = peripheral.find("modem") or error("No modem attached", 0)

MY_ID = math.random(99)
RECIPIENTS = {MY_ID}

modem.open(MY_ID)
function sleep(delay)
	time = os.clock()
	while os.clock()<time+delay do
		os.sleep(0)
	end
end
function tableConcat(tab,delim)
	txt = ""
	if(#tab==1)then return tostring(tab[1]) end
	for i=1,#tab-1 do
		txt = txt..tab[i]..delim
	end
	txt=txt..tab[#tab]
	return txt
end
function Check(ID)
	if(ID==nil)then return false end
	for i,v in ipairs(RECIPIENTS) do
		if(v==ID)then return true end
	end
	return false
end
function Recieve(timeout)
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
			if(not Check(replyChannel)) then RECIPIENTS[#RECIPIENTS+1]=replyChannel end
			messages[replyChannel] = message
		until os.clock()>Time+timeout
	end
	parallel.waitForAny(timer,msg_rcv)
	return messages
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
	if(Check(reply))then 
		txt = tableConcat(RECIPIENTS,",")
	else
		txt = " ["..tostring(os.clock()).."] New one ("..tostring(reply)..")! Ping is "..tostring(msg[2]-msg[1])
	end
	term.write(txt)
end
function NETERROR(reply,channel,msg)
	Send(reply,"ERROR 400")
end
function TERMINATE(...)
	modem.closeAll()
	os.reboot()
end
function SEND_REC_LIST(reply,channel,msg)
	Send(reply,RECIPIENTS)
end

function LIST(...)
	return RECIPIENTS
end
function Exec(func,...)
	local CMDS = {["LIST"]=LIST}
	return CMDS[func](...)
end
function resolve(reply,msg)
	local CMDS = {["FWD"]=FWD,["BACK"]=BACK,["PING"]=PING,["RESPONSE"]=PING_RESPONSE,["SRL"]=SEND_REC_LIST,["TERMINATE"]=TERMINATE}
	CMDS[msg[1][1]](reply,msg[1][2],msg[2])
end

function discover(channel_limit)
	for i=1,channel_limit do
		Send(i,{{"PING",MY_ID},os.clock()})
	end
end



print("discovering...")


while(true) do
	io.read()
	discover(100)
	term.write(" RECIPIENTS:("..tableConcat(RECIPIENTS,",")..") ["..os.clock().."]")
	messageQueue = Recieve(1)
	for reply,msg in pairs(messageQueue) do
		resolve(reply,msg)
	end
	for recipient=1,#RECIPIENTS do
		if(RECIPIENTS[recipient]~=MY_ID)then
		MSG = {{"BACK",MY_ID},{"LIST"}}
		modem.transmit(RECIPIENTS[recipient],RECIPIENTS[recipient],MSG)
	end end
	term.clearLine()
	x,y = term.getCursorPos()
	term.setCursorPos(0,y)
end