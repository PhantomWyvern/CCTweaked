-- 1.0.1
local box = peripheral.wrap("left") or error("No box found", 0)
local monitor = peripheral.find("monitor") or error("No monitor found", 0)
monitor.setTextScale(0.5) -- idk how to wrap the text onto the next line if too long so i made it super small (max size monitor suggested)
local with, height = monitor.getSize()
monitor.clear()
line = 1

local function logs(log, line) --self explanitory imo
    local file = fs.open("logs.txt", "a") --wipes the logs file every reset to make it easier to search
    monitor.setCursorPos(1, line)
    monitor.write(log)
    line = line + 1
    file.writeLine(log)
    print(log)
    file.close()
    return line
end

while true do
    while line < height do 
        local event, username, message = os.pullEvent()
        utcTime = os.epoch("utc") / 1000
        X = 3600
        correctedTime = utcTime + X
        formattedDate = os.date("[%H:%M:%S] ", correctedTime) --why request the time when its not that long of a function
        if event == "chat" then
            log = (formattedDate .. username .. ": " .. message)
            monitor.setTextColor(colors.white) --helps distinguish the different actions like in the server
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
    line = 1 --line reset
    monitor.clear() -- idk how to move all the text up one so it wipes the while screen once it reaches the end
end