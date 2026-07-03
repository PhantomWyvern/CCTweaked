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

while true do
    local energyC = cube.getEnergy()
    os.sleep(1)
    local energyCA = cube.getEnergy()
    rate = energyCA - energyC
    if rate <= 0 then
        rate = math.abs(rate)
        rateF = formatEnergy(rate)
        sign = " -"
    else
        rateF = formatEnergy(rate)
        sign = " +"
    end
    energyCF = formatEnergy(energyC)
    local energyM = cube.getMaxEnergy()
    energyMF = formatEnergy(energyM)
    energy = energyCF .. "/" .. energyMF .. sign .. "(" .. rateF .. "/s)"
    modem.transmit(54, 14, energy)
    print("transmitted: " .. energy)
    
    percentage = ((energyC / energyM) * 100)
    fpercentage = string.format("%.4f", percentage)
    percent = (fpercentage .. "% full")
    --modem.transmit(52, 14, percent) --keeping incase not worked
    --print("transmitted: " .. percent)
    modem.transmit(51, 14, fpercentage)
    print("transmitted: " .. fpercentage)
    os.sleep(1)
end
    