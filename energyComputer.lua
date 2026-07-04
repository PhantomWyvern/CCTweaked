-- 1.0.5
local modem = peripheral.find("modem") or error("No modem found", 0)
os.sleep(1)
local cube = peripheral.wrap("bottom") or error("No cube found", 0)
energyM = cube.getMaxEnergy()

local function formatEnergy(energy)
    local suffixes = {"", "k", "M", "G", "T", "P"}
    local suffixIndex = 1
    if energy <= 0 then return "0FE" end
    while energy >= 1000 and suffixIndex < #suffixes do
        energy = energy / 1000
        suffixIndex = suffixIndex + 1
    end
    local formatted = string.format("%.1f", energy)
    if string.sub(formatted, -2) == ".0" then
        formatted = string.sub(formatted, 1, -3)
    end
    return formatted .. suffixes[suffixIndex] .. "FE"
end

local function EnergyAmmount(energyC, energyM)
    energyCF = formatEnergy(energyC)
    energyMF = formatEnergy(energyM)
    return energyCF .. "/" .. energyMF
end

local function EnergyPerSecond(energyC, energyCA)
    local rate = energyCA - energyC
    if rate <= 0 then
        rate = math.abs(rate)
        return "-" .. formatEnergy(rate) .. "/s"
    else
        return "+" .. formatEnergy(rate) .. "/s"
    end
end

local function TimeLeft(energyC, energyCA, energyM)
    local rate = energyCA - energyC
    if rate == 0 then
        return " (INF)"
    else
        if rate < 0 then
            local timeLeft = math.abs(energyC / rate)
            timeLeft = os.date("%H:%M:%S", timeLeft)
            return "" .. timeLeft .. " left"
        else
            local timeLeft = math.abs((energyM - energyC) / rate)
            if timeLeft > 86400 then
                --timeLeft = string.format("%d days, %H:%M:%S", timeLeft)
                print("Time left: " .. timeLeft)
                return " (>24h left)"
            else
                timeLeft = os.date("%H:%M:%S", timeLeft)
                return "(" .. timeLeft .. " left)"
            end
        end
    end
end

while true do
    energyC = cube.getEnergy()
    os.sleep(1)
    energyCA = cube.getEnergy()

    EnergyPerSec = EnergyPerSecond(energyC, energyCA)
    EnergyQuantity = EnergyAmmount(energyC, energyM)
    TimeRemaining = TimeLeft(energyC, energyCA, energyM)

    energy = (EnergyPerSec .. " " .. EnergyQuantity .. " " .. TimeRemaining)
    modem.transmit(54, 14, energy)
    print("transmitted ID 54: " .. energy)
    
    percentage = ((energyC / energyM) * 100)
    fpercentage = string.format("%.4f", percentage)
    fpercent = tonumber(fpercentage)
    os.sleep(1)
    modem.transmit(53, 14, fpercent)
    print("transmitted ID 52: " .. fpercentage)
    os.sleep(1)
end
    