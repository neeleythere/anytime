-- Written by ausmel105
-- 16th of August, 2018

--[[IMPORTANT: GENERATE YOUR OWN UNIQUE KEY OTHERWISE THIS WILL NOT WORK!
    
    1. Open your web browser and navigate to: https://console.developers.google.com/flows/enableapi?apiid=timezone_backend&keyType=SERVER_SIDE&reusekey=true
    2. Sign into Google if you have not already done so.
    3. Select "Create a new project" and click on "Continue"
    4. Wait for Google to create your project.
    5. When asked for a name and IP addresses to accept requests from, DO NOT CHANGE ANYTHING. Simply click on "Create".
    6. You now have your very own key!
    
--]]

local key = "" -- API key here

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local instantiate = script:WaitForChild("RemoteFunction")

math.randomseed(tick())

local anyTime = {}
anyTime.__index = anyTime

function anyTime.new(coordinates)
    if RunService:IsRunMode() or RunService:IsServer() then
        local newTime = {}
        setmetatable(newTime, anyTime)
        
        newTime.data = anyTime:_fetchTimeZoneData(coordinates)
        
        if newTime.data.status == "OK" then
            newTime.coordinates = coordinates
            newTime.offset = newTime.data["rawOffset"] + newTime.data["dstOffset"]
            newTime.location = newTime.data["timeZoneId"]
            newTime.timezone = newTime.data["timeZoneName"]
            newTime.epoch = os.time() + newTime.offset
            newTime.time = anyTime.convertTime(newTime.epoch)
            return newTime.data.status, newTime
        else
            local errormsg = newTime.data.status
            newTime = nil
            return errormsg
        end
    else
        local status, newTime = instantiate:InvokeServer(coordinates)
        if newTime then
            local obj = setmetatable(newTime, anyTime)
            return status, obj
        else
            return status
        end
    end
end

function anyTime:_getProperties()
    local properties = {}
    for i, v in pairs(self) do
        properties[i] = v
    end
    return properties
end

function anyTime:_fetchTimeZoneData(coordinates) 
    local response = HttpService:GetAsync("https://maps.googleapis.com/maps/api/timezone/json?location="..tostring(coordinates[1])..","..tostring(coordinates[2]).."&timestamp="..os.time().."&key="..key, true)
    local decodedResponse = HttpService:JSONDecode(response)
    return decodedResponse
end

function anyTime:_synchroniseTime()
    local prior = self.epoch
    self:_sendToOutputStream("Prior to sync, t = "..prior.." seconds from UNIX")
    self.epoch = os.time() + self.offset
    self:_sendToOutputStream("Following sync, t = "..self.epoch.." seconds from UNIX")
    self:_sendToOutputStream("Inaccuracy = "..self.epoch - prior.." seconds")
    self:_sendToOutputStream("Next sync @ "..self.convertTime(self.epoch + (180 - (self.epoch % 180))))
end

function anyTime:_sendToOutputStream(msg)
    if self.console_output then
        self.console_output:Fire(msg)
    end
end

function anyTime.waitForTick()
    local beginTime = os.time()
    repeat until beginTime ~= os.time()
end

function anyTime:tick()
    local timeWaiting = 0
    repeat
        local timeWaited = wait(1/10)
        timeWaiting = timeWaiting + timeWaited
    until timeWaiting >= 1
    
    self.epoch = self.epoch + timeWaiting
    
    --self.time = anyTime.convertTime(self.epoch)
    print("tick")
    
    coroutine.wrap(function()
        print("EPOCH =", self.epoch)
        print(math.floor(self.epoch), "% 180 =", math.floor(self.epoch) % 180, "\n")
        if (math.floor(self.epoch) % 180) == 0 then
            self:_synchroniseTime()
        end
        self.time = anyTime.convertTime(self.epoch)
    end)()
        
end

function anyTime:getConsoleStream()
    if self.console_output == nil then
        local event = Instance.new("BindableEvent")
        self.console_output = event
        return event        
    else
        return self.console_output
    end
end

function anyTime:Cleanup()
    self:_sendToOutputStream("Deleting output stream")
    self.console_output:Destroy()       
end

function anyTime.convertTime(seconds)
  local hh = (seconds / (60 * 60)) % 24
  local mm = (seconds / (60)) % 60
  local ss = (seconds) % 60
  return string.format("%02d:%02d:%02d", math.floor(hh), math.floor(mm), math.floor(ss))
end

return anyTime
