zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	While the machine is producing it will change its Temperatur goal
	The player needs to adjust the Temperatur pointer in order for the Temperatur to stay cool
	Failing to adjust the Temperatur pointer to the goal will cause the Temperatur to go up

*/

local Temperatur = zpm.Machine.Temperatur or {}

local left_pos = Vector(-83, -70, 25)
function Temperatur:OnLeft(Machine,ply)
	local trace = ply:GetEyeTrace()

	local pos = Machine:LocalToWorld(left_pos)
    if zclib.util.InDistance(pos, trace.HitPos, 3) then
        return true
    else
        return false
    end
end

local right_pos = Vector(-56, -70, 25)
function Temperatur:OnRight(Machine,ply)
	local trace = ply:GetEyeTrace()

	local pos = Machine:LocalToWorld(right_pos)
    if zclib.util.InDistance(pos, trace.HitPos, 3) then
        return true
    else
        return false
    end
end

zpm.Machine.Temperatur = Temperatur
