-- Example usage of AnyTime module.
-- The AnyTime module will be moved to ReplicatedStorage, so you'll need to look for it there.

local rs = game:GetService("ReplicatedStorage")
local anyTime = require(rs:WaitForChild("AnyTime"))

local input_display = script.Parent.Frame
local output_display = script.Parent.Parent.output_display.Frame

local clock

function createClock(coordinates)
    clock = anyTime.new(coordinates)
    coroutine.wrap(function()
        local currentClock = clock
        while clock == currentClock do
            output_display.time.Text = clock.time
            clock:tick()
        end
    end)()
    return clock
end

input_display.submit.MouseButton1Click:Connect(function()
<<<<<<< HEAD
    clock = nil
    local latitude = tonumber(input_display.latitude.Text)
    local longitude = tonumber(input_display.longitude.Text)
    if (latitude == nil) or (longitude == nil) then
        input_display.errormsg.Visible = true
        return
    end
    input_display.errormsg.Visible = false
    createClock({latitude, longitude})
    output_display.location.Text = clock.location
    output_display.timezone.Text = clock.timezone
end)
=======
	clock = nil
	local latitude = tonumber(input_display.latitude.Text)
	local longitude = tonumber(input_display.longitude.Text)
	if (latitude == nil) or (longitude == nil) then
		input_display.errormsg.Visible = true
		return
	end
	input_display.errormsg.Visible = false
	createClock({latitude, longitude})
	output_display.location.Text = clock.location
	output_display.timezone.Text = clock.timezone
end)
>>>>>>> c3ceb5009850d5364bb49fbcf82556c81926bffb
