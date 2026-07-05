-- 1.1.3
local modem = peripheral.find("modem") or error("No modem found", 0)
modem.open(21)

local function GetTime() -- no i havnt tried inputting UTC+1 but if it aint broke dont fix it
    utcTime = os.epoch("utc") / 1000 --os.time doesnt support "GMT" so i have to manually add an hour from UTC
    X = 3600
    correctedTime = utcTime + X
    formattedDate = os.date("%a %d %b %Y                  %I:%M %p", correctedTime)
    modem.transmit(1, 21, formattedDate)
    print("transmitted From ID 21:" .. formattedDate) --debug 
end

while true do --listens out for Central Server request before sending (reduces traffic)
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until replyChannel == 1 -- checks if the channel is the Main Server
    print("Requested time from Central Server") --debug
    GetTime()
    os.sleep(1)
end