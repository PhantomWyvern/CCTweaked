-- 1.0.3
local modem = peripheral.find("modem") or error("No modem found", 0)

while true do
    utcTime = os.epoch("utc") / 1000
    X = 3600
    correctedTime = utcTime + X
    formattedDate = os.date("%a %d %b %Y                  %I:%M %p", correctedTime)
    modem.transmit(55, 14, formattedDate)
    print("transmitted ID 55:" .. formattedDate)
    os.sleep(1)
end