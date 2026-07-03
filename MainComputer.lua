-- 1.0.5
local monitor = peripheral.find("monitor") or error("No monitor found", 0)
local modem = peripheral.find("modem") or error("No modem found", 0)
local width, height = monitor.getSize()
Version = "V1.0.5"
monitor.setTextScale(2)
monitor.setBackgroundColor(colors.black)
monitor.clear()

--todo list
--storage reader and display
--dt fuel display switching with energy display
--energy remaining display (or time till fulll charge if positive)
--play sound when player joins or leaves the server?
--day or night from clock pc

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
setup(18,10, colors.green, colors.black, "Energy:") -- dt fuel display change in future

local function recieveMessage(channelnum)
    modem.open(channelnum)
    local timerID = os.startTimer(5)
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
    until event == "timer" or (event == "modem_message" and channel == channelnum)

    if event == "modem_message" then
        return message
    else
        message = "error"
        print("error, message not recieved, please check computer with ID: " .. channelnum)
        return message
    end

    modem.close(channelnum)
    os.cancelTimer(timerID)
end

local function Time() 
    time = recieveMessage(55)
    setup(1, 3, colors.green, colors.black, time)
    --print("message recieved: " .. time) --debug text
end

local function Energy()
    energy = recieveMessage(54)
    setup(1, 11, colors.green, colors.black, energy)
    --print("message recieved: " .. energy) --debug text
end

local function Percent() 
    local percentage = (recieveMessage(53) .. "% fulll")
    setup(15, 12, colors.green, colors.black, percentage)
    --print("message recieved: " .. percentage) --debug text
end

local function energyBar() -- unknown if setup will work with this
    local percentage = tonumber(recieveMessage(52))
    percent = percentage / 100
    filledLength = (width * percent)
    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.gray)
    monitor.write(string.rep(" ", width))

    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.green)
    monitor.write(string.rep(" ", filledLength))
    --print("message recieved: " .. percentage) --debug text
end

while true do
    Time()
    Energy()
    Percent()
    energyBar()
    os.sleep(1)
end