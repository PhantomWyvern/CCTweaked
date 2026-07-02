local modem = peripheral.find("modem") or error("No modem found", 0)

while true do
    utcTime = os.epoch("utc") / 1000
    X = 3600
    correctedTime = utcTime + X
    formattedDate = os.date("%a %d %b %Y                         %H:%M", correctedTime)
    modem.transmit(55, 14, formattedDate)
    print("transmitted: " .. formattedDate)
    os.sleep(1)
end