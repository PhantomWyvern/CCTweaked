-- 1.1.1
local modem = peripheral.find("modem") or error("No modem found", 0)
local monitor = peripheral.find("monitor") or error("no monitor found", 0)
modem.open(101)
monitor.setTextScale(0.5)
width, height = monitor.getSize()
line = 1

local function debugLog(message, line)
    -- error code meaning
    -- 0 = no error, just Log
    -- 101 = no message recieved
    local file = fs.open("debugLog.txt", "w") --empties the file upon reboot
    file.close()
    local file = fs.open("debugLog.txt", "a")
    file.writeLine(message)
    print(message)
    file.close()
    monitor.setCursorPos(1, line)
    monitor.write(message)
    line = line + 1
    return line
end

while true do -- waits for Main computer to request a specific piece of data
    local event, side, channel, replyChannel, message, distance 
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until replyChannel = 1 -- check if the channel is the main PC requesting data
    debugLog(message, line)
    if line < height then
        line = line + 1
    else
        line = 1
    os.sleep(1)
end