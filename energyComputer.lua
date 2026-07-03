local modem = peripheral.find("modem") or error("No modem found", 0)
os.sleep(1)
local cube = peripheral.wrap("bottom") or error("No cube found", 0)

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
        return " (-" .. formatEnergy(rate) .. "/s)"
    else
        return " (+" .. formatEnergy(rate) .. "/s)"
    end
end

local function TimeLeft(energyC, energyCA, energyM)
    local rate = energyCA - energyC
    if rate == 0 then
        return " (INF)"
    else
        rate = string.format("%H,%M,%S", rate)
        if rate < 0 then
            local timeLeft = math.abs(energyC / rate)
            return " (" .. timeLeft .. " left)"
        else
            local timeLeft = math.abs((energyM - energyC) / rate)
            return " (" .. timeLeft .. " left)"
        end
    end
end

while true do
    energyC = cube.getEnergy()
    os.sleep(1)
    energyCA = cube.getEnergy()
    energyM = cube.getMaxEnergy()

    EnergyPerSecond = EnergyPerSecond(energyC, energyCA)
    EnergyAmmount = EnergyAmmount(energyC, energyM)
    TimeLeft = TimeLeft(energtyC, energyCA, energyM)

    energy = (EnergyPerSecond "     " .. EnergyAmmount .. "     " .. TimeLeft)
    modem.transmit(54, 14, energy)
    print("transmitted: " .. energy)
    
    percentage = ((energyC / energyM) * 100)
    fpercentage = string.format("%.4f", percentage)
    percent = (fpercentage .. "% full")
    --modem.transmit(52, 14, percent) --keeping incase test fail
    --print("transmitted: " .. percent)
    modem.transmit(51, 14, fpercentage)
    print("transmitted: " .. fpercentage)
    os.sleep(1)
end
    