zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*
    While the machine is producing it will change its Temperatur goal
    The player needs to adjust the Temperatur pointer in order for the Temperatur to stay cool
    Failing to adjust the Temperatur pointer to the goal will cause the Temperatur to go up
*/

-- Create the Temperatur table if it doesn't exist, or use the existing one
local Temperatur = zpm.Machine.Temperatur or {}

/*
    Called once a new cycle starts
*/
function Temperatur:ChangeTarget(Machine)
    -- Randomly set a new temperature target for the machine (50% chance of not changing target)
    if math.random(10) < 5 then return end
    Machine:SetTemperaturTarget(math.random(2,9))
end

-- Adjusts the temperature pointer based on player input
function Temperatur:Change(Machine,ply)

	if not zpm.config.Machine.Temperatur.enabled then return end

    if Temperatur:OnLeft(Machine,ply) then
        Temperatur:Decrease(Machine)
        return true
    end

    if Temperatur:OnRight(Machine,ply) then
        Temperatur:Increase(Machine)
        return true
    end
    return false
end

-- Increases the temperature pointer by 1, clamping it between 1 and 10
function Temperatur:Increase(Machine)
    Machine:SetTemperaturPointer(math.Clamp(Machine:GetTemperaturPointer() + 1,1,10))

    Temperatur:Updated(Machine)
end

-- Decreases the temperature pointer by 1, clamping it between 1 and 10
function Temperatur:Decrease(Machine)
    Machine:SetTemperaturPointer(math.Clamp(Machine:GetTemperaturPointer() - 1,1,10))

    Temperatur:Updated(Machine)
end

/*
    Called once we changed the temperatur pointer
*/
local temp_pos = Vector(-82.5, -56, 42.5)
function Temperatur:Updated(Machine)
    -- Emit a sound effect to indicate the temperature change
    zclib.Sound.EmitFromPosition(Machine:LocalToWorld(temp_pos),"zpm_temperatur_change")
    -- If the temperature pointer is now at the target temperature, emit a matching sound effect
    if Machine:GetTemperaturPointer() ~= Machine:GetTemperaturTarget() then
        return
    end
    zclib.Sound.EmitFromPosition(Machine:LocalToWorld(temp_pos),"zpm_temperatur_match")
end

/*
	Checks the temperature of a machine and adjusts it as necessary
*/
util.AddNetworkString("zpm.Machine.Temperatur.Explode")
function Temperatur:Check(Machine)

	if not zpm.config.Machine.Temperatur.enabled then return end

	-- If the machine's temperature pointer is not at the target temperature
	if Machine:GetTemperaturPointer() ~= Machine:GetTemperaturTarget() then
		-- Increase the machine's temperature by 1, clamping it between 0 and 100
		Machine:SetTemperatur(math.Clamp(Machine:GetTemperatur() + 1,0,100))
	else
		-- Decrease the machine's temperature by 1, clamping it between 0 and 100
		Machine:SetTemperatur(math.Clamp(Machine:GetTemperatur() - 1,0,100))
	end

	-- If the machine's temperature is at or above 100
	if Machine:GetTemperatur() >= 100 then

		-- Trigger an explosion effect on the machine
		net.Start("zpm.Machine.Temperatur.Explode")
		net.WriteEntity(Machine)
		net.Broadcast()

		-- Stop production on the machine
		zpm.Machine.StopProduction(Machine)
	end
end


zpm.Machine.Temperatur = Temperatur
