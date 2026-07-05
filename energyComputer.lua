-- 1.1.3
local modem = peripheral.find("modem") or error("No modem found", 0)
local cube = peripheral.wrap("bottom") or error("No cube found", 0)
modem.open(22)
modem.open(23)
energyM = cube.getMaxEnergy() --max energy wont change so we check it now

local function formatEnergy(energy)
    local suffixes = {"", "k", "M", "G", "T", "P"} --prefixes for makenism energy (need to modify if ever above PFE)
    local suffixIndex = 1
    if energy <= 0 then return "0FE" end --if empty, return 0FE, no formating needed
    while energy >= 1000 and suffixIndex < #suffixes do --moves down the suffixes array untill the propper suffix is reached
        energy = energy / 1000
        suffixIndex = suffixIndex + 1
    end
    local formatted = string.format("%.1f", energy) -- 1 decimal point
    if string.sub(formatted, -2) == ".0" then --if the last two digits are .0, remove them
        formatted = string.sub(formatted, 1, -3)
    end
    return formatted .. suffixes[suffixIndex] .. "FE" --Adds at the end of the number FE ontop of that
end

local function EnergyAmmount(energyC, energyM) -- 1/3 that make up the line, self explanitory function
    energyCF = formatEnergy(energyC)
    energyMF = formatEnergy(energyM)
    return energyCF .. "/" .. energyMF
end

local function EnergyPerSecond(energyC, energyCA) -- 2/3 that make up the line, energy per second based on 2 readings 1s appart
    local rate = energyCA - energyC
    if rate <= 0 then
        rate = math.abs(rate) --turns a negative into a positive to prevent format throwing 0FE
        return "-" .. formatEnergy(rate) .. "/s"
    else
        return "+" .. formatEnergy(rate) .. "/s"
    end
end

local function TimeLeft(energyC, energyCA, energyM) -- 3/3 that make up the line, how long till full / empty of storage
    local rate = energyCA - energyC --energy currently After 1s - energy currently (before)
    if rate == 0 then
        return " (INF)"
    else
        if rate < 0 then -- uhhhhh do i need this???
            local timeLeft = math.abs(energyC / rate)
            timeLeft = os.date("%H:%M:%S", timeLeft)
            return timeLeft .. " left"
        else
            local timeLeft = math.abs((energyM - energyC) / rate)
            if timeLeft > 86400 then -- im too lazy to format anything over a day
                print("Time left: " .. timeLeft) --debug message (and cause im curious)
                return " >24h left"
            else
                timeLeft = os.date("%H:%M:%S", timeLeft)
                return "(" .. timeLeft .. " left)"
            end
        end
    end
end

local function Energy() -- formats all 3 into the line
    energyC = cube.getEnergy()
    os.sleep(1)
    energyCA = cube.getEnergy()
    EnergyPerSec = EnergyPerSecond(energyC, energyCA)
    EnergyQuantity = EnergyAmmount(energyC, energyM)
    TimeRemaining = TimeLeft(energyC, energyCA, energyM)

    energy = (EnergyPerSec .. " " .. EnergyQuantity .. " " .. TimeRemaining)
    modem.transmit(1, 22, energy)
    print("transmitted from ID 22: " .. energy)
end

local function Percentage() -- gives the percentage full the energy storage is at (refer to main computer documentation for reason no % addded)
    energyC = cube.getEnergy()
    percentage = ((energyC / energyM) * 100)
    fpercentage = string.format("%.4f", percentage) -- 4 decimal points only because my storage is at PFE and it literally goes up by 0.0001 every 2s (feel free to change)
    fpercent = tonumber(fpercentage) --error if not number idk why
    modem.transmit(1, 23, fpercent)
    print("transmitted from ID 23: " .. fpercentage) --debug
end

while true do
    local event, side, channel, replyChannel, message, distance 
    repeat --listens out for Central Server request before sending (reduces traffic)
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until replyChannel == 1 -- checks if the channel is the Main Server
    if channel == 22 then -- if statement cause one computer manages 2 different lines
        Energy()
    elseif channel == 23 then
        Percentage()
    end
end
    