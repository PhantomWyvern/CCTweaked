--Credit to mikeywhiston for the original code (slightly modified for my use)
local function compare_version_strings(v1, v2) --v1 is old, v2 is github version
  local split1, split2 = {}, {}
  for v in v1:gmatch('([0-9]+)%.?') do
    split1[#split1 + 1] = tonumber(v)
  end
  for v in v2:gmatch('([0-9]+)%.?') do
    split2[#split2 + 1] = tonumber(v)
  end

  for i, v1 in ipairs(split1) do
    local v2 = split2[i]
    if v2 and v1 > v2 then return true end
  end
  return false
end

function split_by_char(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

local function get_current_version()
    local function try_get_current() 
        local current_file_open = fs.open('temp.lua', 'r') --changed from startup.lua
        local file_comment_str = current_file_open.readLine()
        current_file_open.close()
    end

    if pcall(try_get_current) then
        local current_file_open = fs.open('temp.lua', 'r') --changed from startup.lua
        local file_comment_str = current_file_open.readLine()
        local version_string = file_comment_str:match('^-- ([0-9%.]+)')
        current_file_open.close()
        return version_string
    else
        return 0
    end
end

local function fetch_current_version()
    local url = "https://raw.githubusercontent.com/repos/PhantomWyvern/CCTweaked/contents/clockComputer.lua" --change filename to correct pc filepath
    local resp, err = http.get(url)
    if fs.exists('temp2.lua') then -- changed from temp.lua
        fs.delete('temp2.lua') -- changed from temp.lua
    end
    local file = fs.open('temp2.lua', 'w') -- changed from temp.lua
    file.write(resp.readAll())
    if resp ~= nil then
      resp.close()
    else
      error(err)
    end
    file.close()
end

local function read_temp_version()
    file = fs.open('temp2.lua', 'r') -- changed from temp.lua
    version_string = file.readLine()
    version_string = version_string:match('^-- ([0-9%.]+)')
    file.close()
    return version_string
end

local function replace_current_file()
    fs.delete('temp.lua') -- changed from startup.lua
    fs.move('temp2.lua', 'temp.lua')  -- changed from both
    os.reboot()
end

shell.openTab("temp.lua")
while true do
    local success, err = pcall(function()
        --response, err = http.post(server_addr .. '/push_activation', textutils.serializeJSON(resp), {["Content-Type"] = "application/json"}) --dont think so?
        if response ~= nil then
          response.close()
        else
          print(err)
        end
        print('POSTED')
    end)
    print('CHECKING SOURCE CONTROL ...')
    fetch_current_version()
    print(get_current_version())
    print(read_temp_version())
    if compare_version_strings(read_temp_version(), get_current_version()) == true then
        print('REBOOTING TO APPLY CHANGES')
        replace_current_file()
    else
        print('UP TO DATE')
    end
    os.sleep(5)
end
