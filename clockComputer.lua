-- 1.1.1
local modem = peripheral.find("modem") or error("No modem found", 0)
modem.open(21)

local function GetTime()
    utcTime = os.epoch("utc") / 1000
    X = 3600
    correctedTime = utcTime + X
    formattedDate = os.date("%a %d %b %Y                  %I:%M %p", correctedTime)
    modem.transmit(1, 21, formattedDate)
    print("transmitted ID 55:" .. formattedDate)
end
while true do
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until replyChannel = 1 -- checks if the channel is the Main Server
    GetTime()
    os.sleep(1)
end