-- 1.1.5
local modem = peripheral.find("modem") or error("No modem found", 0)
modem.open(1)

local function IRLTime() --for logs
    utcTime = os.epoch("utc") / 1000
    X = 3600
    correctedTime = utcTime + X
    formattedDate = os.date("[%H:%M:%S] ", correctedTime)
    return formattedDate
end

local function debugLog(problem_code, message)
    -- error code meaning
    -- 0 = no error, just Log
    -- 101 = no message recieved
    local time = IRLTime()
    local log = (time .. " " .. problem_code .. ": " .. message) --make it easier to search the logs for debugging
    modem.transmit(100, 1, log)
    print("Transmitted log to ID: 100: " .. log) --debug message
end

local function recieveData(channelnum) --old function still works, not repurposed yet, read the other documentation for how this works
    print("requesting data from ID: " .. channelnum) --debug message
    timerID = os.startTimer(10) 
    log = ("+ Timer started and channel open: ".. channelnum) -- debug text
    debugLog(0 , log)
    modem.transmit(channelnum, 1, "request")
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
    until event == "timer" or (event == "modem_message" and replyChannel == channelnum)

    if event == "modem_message" and replyChannel == channelnum then
        debugLog(0, ("+ message: ".. channelnum)) -- debug text
        os.cancelTimer(timerID)
        debugLog(0, ("- Timer:" .. channelnum)) --debug text
        return message
    else -- the problem --
        debugLog(101, ("- Message not: ".. channelnum)) -- debug text
        os.cancelTimer(timerID)
        end
    end

local data = { --stores data here incase last request failed to recieve, will still break if error on startup
    ["time"] = 0,
    ["energy"] = 0,
    ["percentage"] = 0
}

local RequestID = { --idk why this is here when the main computer states which modem the server needs to request from (this only here for info)
    [1] = "MainServer", -- wont be used but for info
    [10] = "MainComputer", -- also wont be used but for info
    [21] = "time", --clock PC
    [22] = "energy", --energy PC
    [23] = "percentage", --energy PC
    [100] = "LogComputer" --Logs PC
}

function storeData(key, value) -- stores the data in table
    data.key = value
    print(data.key .. "now set to " .. value)
end

function getData(key) 
    return data.key 
end

local function dataRequest(channelnum) --sends a request to the requested modem for its contents, returns and stores the data gathered
    channel = tonumber(channelnum)
    temp = recieveData(channelnum)
    if temp ~= nil then --if the request was successful, store it in data table
        ID = RequestID[channel]
        --print("ID: " .. ID)
        storeData(ID, temp)
        return ID
    else
        print("Error: " .. channelnum .. " failed to send / recieve data")
    end
end

while true do -- waits for Main computer to request a specific piece of data
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until replyChannel == 10 -- check if the channel is the main PC requesting data
    message = tonumber(message)
    -- where the problems start --
    ID = dataRequest(message) --sends a request to the pc it needs info from and stores it in table if error, fuck
    info = getData(message) --retrieves the info from table
    print(info)
    modem.transmit(10, 1, info) --sends it back to main computer
    print("Transmitting data to Main Computer: " .. info)
    os.sleep(1)
end