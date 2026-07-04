-- 1.0.9
local monitor = peripheral.find("monitor") or error("No monitor found", 0)
local modem = peripheral.find("modem") or error("No modem found", 0)
local width, height = monitor.getSize()
Version = "V1.0.9"
monitor.setTextScale(2)
monitor.setBackgroundColor(colors.black)
monitor.clear()

--todo list
--storage reader and display
--dt fuel display switching with energy display
--play sound when player joins or leaves the server?
--day or night from clock pc

local function debugLog(error, message)
    -- error code meaning
    -- 0 = no error, just Log
    -- 101 = no message recieved
    local file = fs.open("filename.txt", "w") --empties the file
    file.close()
    local file = fs.open("debugLog.txt", "a")
    file.writeLine(error .. ": " .. message)
    print(error .. ": " .. message)
    file.close()
end


local function setup(xpos, ypos, textcolor, backgroundcolor, text)
    
    monitor.setCursorPos(xpos, ypos)
    monitor.setBackgroundColor(backgroundcolor)
    monitor.clearLine()
    monitor.setTextColor(textcolor)
    monitor.write(text)
end

-- Static text setup
monitor.clear()
setup(17, 1, colors.red, colors.black, "DragonOS         " .. Version)
setup(1, 2, colors.red, colors.black, "-----------------------------------------")
setup(1, 3, colors.white, colors.black, "Booting...")
os.sleep(3) -- allows for messages to start transmitting before the display is updated (prevents errors)
monitor.clearLine()
setup(18,10, colors.green, colors.black, "Energy:") -- dt fuel display change in future

local function recieveMessage(channelnum)
    modem.open(channelnum)
    timerID = os.startTimer(10) --might remove in next version
    log = ("timer started and channel open: ".. channelnum) -- debug text
    debugLog(0 , log)
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
    until event == "timer" or (event == "modem_message" and channel == channelnum)

    if event == "modem_message" then
        log = ("message recieved from ID: ".. channelnum) -- debug text
        debugLog(0, log)
        modem.close(channelnum)
        os.cancelTimer(timerID)
        log = ("Timer stopped, modem closed: " .. channelnum) --debug text
        debugLog(0, log)
        return message
    else
        message = "error"
        log = ("message not recieved from ID: " .. channelnum)
        debugLog(101, log)
        modem.close(channelnum)
        os.cancelTimer(timerID)
        log = ("Timer stopped, modem closed: " .. channelnum) --debug text
        debugLog(0, log)
        return message
    end
end

local function Time() 
    time = recieveMessage(55)
    setup(1, 3, colors.green, colors.black, time)
end

local function Energy()
    energy = recieveMessage(54)
    setup(1, 11, colors.green, colors.black, energy)
end

local function energyBar() -- unknown if setup will work with this
    local recieved_percentage = recieveMessage(53)
    percentage = recieved_percentage .. "% full"
    setup(15, 12, colors.green, colors.black, percentage)
    percent = recieved_percentage / 100
    filledLength = (width * percent)
    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.white)
    monitor.write(string.rep(" ", width))

    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.green)
    monitor.write(string.rep(" ", filledLength))
end

while true do
    Time()
    os.sleep(1)
    Energy()
    os.sleep(1)
    energyBar()
    os.sleep(1)
end