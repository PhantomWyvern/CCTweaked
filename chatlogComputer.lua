local box = peripheral.wrap("left") or error("No box found", 0)
local monitor = peripheral.find("monitor") or error("No monitor found", 0)
monitor.setTextScale(0.5)
local with, height = monitor.getSize()
monitor.clear()
line = 1

local function logs(log, line)
    local file = fs.open("logs.txt", "a")
    monitor.setCursorPos(1, line)
    monitor.write(log)
    line = line + 1
    file.writeLine(log)
    print(log)
    file.close()
    return line
end

while true do
    while line <= height do
        local event, username, message = os.pullEvent()
        utcTime = os.epoch("utc") / 1000
        X = 3600
        correctedTime = utcTime + X
        formattedDate = os.date("[%H:%M:%S] ", correctedTime)
        if event == "chat" then
            log = (formattedDate .. username .. ": " .. message)
            monitor.setTextColor(colors.white)
            line = logs(log, line)
        end
        if event == "playerLeave" then
            log = (formattedDate .. username .. " has left the server.")
            monitor.setTextColor(colors.red)
            line = logs(log, line)
        end
        if event == "playerJoin" then
            log = (formattedDate .. username .. " has joined the server.")
            monitor.setTextColor(colors.green)
            line = logs(log, line)
        end
    end
    line = 1
    monitor.clear()
end