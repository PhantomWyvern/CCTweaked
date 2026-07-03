local monitor = peripheral.find("monitor") or error("No monitor found", 0)
local modem = peripheral.find("modem") or error("No modem found", 0)
local width, height = monitor.getSize()
version = "1.0.1" -- 1st increases every official release, 2nd increases every successful added features, 3rd for tests and fixes itterations
monitor.setTextScale(2)

--todo list
--storage reader and display
--energy per second display
--energy remaining display (or time till fulll charge if positive)
--play sound when player joins or leaves the server?

local function setup(xpos, ypos, textcolor, backgroundcolor, text)
    monitor.setCursorPos(xpos, ypos)
    monitor.setBackgroundColor(backgroundcolor)
    monitor.clearLine()
    monitor.setTextColor(textcolor)
    monitor.write(text)
end

-- Static text setup
monitor.clear()
setup(17, 1, colors.red, colors.black, "DragonOS")
setup(1, 2, colors.red, colors.bllack, "-------------------------------")
setup(18,10, colors.green, colors.black, "Energy:")

local function recieveMessage(channelnum)
    modem.open(channelnum)
    local timerID = os.startTimer(3)
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
        if event == "timer" then
            message = "error" --this fucks with energy bar when error, need to fix
            print("error, message not recieved, please check computer with ID: " .. channelnum)
            return message
        end
    until event == "modem_message" and channel == channelnum
    modem.close(channelnum)
    os.cancelTimer(timerID)
    return message
end

local function Time() 
    time = recieveMessage(55)
    setup(1, 3, colors.green, colors.black, time)
    --print("message recieved: " .. time) --debug text
end

local function Energy()
    energy = recieveMessage(54)
    setup(12, 11, colors.green, colors.black, energy)
    --print("message recieved: " .. energy) --debug text
end

local function Percent() 
    percentage = (recieveMessage(51) .. "% fulll")
    setup(15, 12, colors.green, colors.black, percentage)
    --print("message recieved: " .. percentage) --debug text
end

local function energyBar() -- unknown if setup will work with this
    percentage = recieveMessage(51)
    percent = percentage / 100
    filledLength = (width * percent)
    setup(1, height, colors.white, colors.white, string.rep(" ", filledlength))
    --monitor.setCursorPos(1, height)
    --monitor.setBackgroundColor(colors.white)
    --monitor.clearLine()
    --monitor.write(string.rep(" ", filledLength)
    setup(1, height, colors.white, colors.green, string.rep(" ", filledlength))
    --monitor.setCursorPos(1, height)
    --monitor.setBackgroundColor(colors.green)
    --monitor.write(string.rep(" ", filledLength))
    --monitor.setBackgroundColor(colors.black)
    print("message recieved: " .. percentage)
end

while true do
    Time()
    Energy()
    Percent()
    energyBar()
    os.sleep(1)
end