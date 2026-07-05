-- 1.1.3
local monitor = peripheral.find("monitor") or error("No monitor found", 0)
local modem = peripheral.find("modem") or error("No modem found", 0)
local width, height = monitor.getSize()
Version = "V1.1.3"
modem.open(10)
monitor.setTextScale(2) -- pre write prep
monitor.setBackgroundColor(colors.black)
monitor.clear()

--todo list
--storage reader and display
--dt fuel display switching with energy display
--play sound when player joins or leaves the server?
--day or night from clock pc
--move %full to over the bar and split the energy section into 2 lines
--auto centering text function
--Cooler bootup screen?
--secure handshake to prevent errors in large multiplayer servers
--have all the data before updating screen?
--make each debug message go to log pc?

local function setup(xpos, ypos, textcolor, backgroundcolor, text) -- self explanitory imo may need to rename
    monitor.setCursorPos(xpos, ypos)
    monitor.setBackgroundColor(backgroundcolor)
    monitor.clearLine()
    monitor.setTextColor(textcolor)
    monitor.write(text)
end

-- Static text setup
setup(17, 1, colors.red, colors.black, "DragonOS         " .. Version)
setup(1, 2, colors.red, colors.black, "-----------------------------------------")
setup(1, 3, colors.white, colors.black, "Booting...")
os.sleep(3) -- allows for the rest of the computers to reboot and get ready (prevents errors)
monitor.clearLine()
setup(18,10, colors.green, colors.black, "Energy:") -- dt fuel display change in future

local RequestID = { -- associates each modem channel ID to the computer / function it should request to
    [1] = "MainServer", -- the only computer it transmits to
    [10] = "MainComputer", -- the pc itself
    [21] = "time", --clock PC
    [22] = "energy", --energy PC
    [23] = "percentage", --energy PC
    [100] = "LogComputer" --Logs PC
}

local function RequestData(channelnum) -- instead of passive listening, it requests it
    modem.transmit(1, 10, channelnum) --sends the request
    timerID = os.startTimer(10) -- prevents it from getting softlocked if 1 pc goes down
    print("Requesting data from channel: " .. channelnum) --debug text
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
    until event == "timer" or (event == "modem_message" and replyChannel == 1) --must be from Center Server to prevent error's
    os.cancelTimer(timerID) -- stops timer no matter which condition is met, ready for next loop
    if event == "modem_message" then
        print("message recieved ID: " .. replyChannel) --debug text
        return message
    else
        print("message not recieved ID: " .. replyChannel) --debug text
        return --returns nothing to prevent errors (unknown)
    end
end

local function Time() 
    time = RequestData(21) -- sends a request for the time
    setup(1, 3, colors.green, colors.black, time) --displays the response on the screen
end

local function Energy() -- split this into 2 lines in next update?
    energy = RequestData(22)
    setup(1, 11, colors.green, colors.black, energy)
end

local function energyBar() -- 1 request, 2 lines to prevent too much traffic or delays so some math is done here
    local recieved_percentage = RequestData(23)
    percentage = recieved_percentage .. "% full" 
    setup(15, 12, colors.green, colors.black, percentage) -- line 1
    percent = recieved_percentage / 100
    filledLength = (width * percent)
    monitor.setCursorPos(1, height) --making a bar on the screen to show progress (i couldnt get it to work using setup)
    monitor.setBackgroundColor(colors.white)
    monitor.write(string.rep(" ", width))

    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.green)
    monitor.write(string.rep(" ", filledLength))
end

while true do -- constantly sends requests to keep the screen updated
    Time()
    os.sleep(1)
    Energy()
    os.sleep(1)
    energyBar()
    os.sleep(1)
end