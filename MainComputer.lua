local monitor = peripheral.find("monitor") or error("No monitor found", 0)
local modem = peripheral.find("modem") or error("No modem found", 0)
local width, height = monitor.getSize()

--todo list
--storage reader and display
--energy per second display
--energy remaining display (or time till fulll charge if positive)

monitor.clear()
monitor.setBackgroundColor(colors.black)
monitor.setCursorPos(17, 1)
monitor.setTextScale(2)
monitor.setTextColor(colors.red) -------make a function to move cursor, change color, clear and write with how often it is used, to make it more efficient
monitor.write("DragonOS")
monitor.setCursorPos(1, 2)
monitor.write("-------------------------------")
monitor.setCursorPos(18, 10)
monitor.setTextColor(colors.green)
monitor.write("Energy:")

local function recieveMessage(channelnum)
    modem.open(channelnum)
    local timerID = os.startTimer(3)
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
        if event == "timer" then
            message = "error"
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
    monitor.setCursorPos(1,3) -------------------- all this could be rewriten with a function to make it more efficient
    monitor.setTextColor(colors.green)
    monitor.clearLine() 
    monitor.write(time) -----------------------
    print("message recieved: " .. time)
end

local function Energy()
    energy = recieveMessage(54)
    energyMax = recieveMessage(53)
    monitor.setCursorPos(12, 11)
    monitor.setTextColor(colors.green)
    monitor.clearLine()
    monitor.write(energy .. "/" .. energyMax) ------------------------ except this one, this one is a bit more complicated because of the formatting
    print("message recieved: " .. energy) 
    print("message recieved: " .. energyMax)- 
end

local function Percent()
    percentage = recieveMessage(52)
    monitor.setCursorPos(15, 12)
    monitor.setTextColor(colors.green)
    monitor.clearLine()
    monitor.write(percentage)
    print("message recieved: " .. percentage)
end

local function energyBar()
    percentage = recieveMessage(51)
    percent = percentage / 100
    filledLength = (width * percent)
    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.white)
    monitor.clearLine()
    monitor.write(string.rep(" ", filledLength)
    monitor.setCursorPos(1, height)
    monitor.setBackgroundColor(colors.green)
    monitor.write(string.rep(" ", filledLength))
    monitor.setBackgroundColor(colors.black)
    print("message recieved: " .. percentage)
end

while true do
    Time()
    Energy()
    Percent()
    energyBar()
    os.sleep(1)
end