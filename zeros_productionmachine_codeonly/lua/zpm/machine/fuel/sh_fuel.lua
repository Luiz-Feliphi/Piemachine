zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	The machine runs on fuel which need to be refilled after some time

*/

local Fuel = zpm.Machine.Fuel or {}

local fuel_pos = Vector(-174, 10, 25)
function Fuel:OnButton(Machine,ply)
	local trace = ply:GetEyeTrace()

	local pos = Machine:LocalToWorld(fuel_pos)
    if zclib.util.InDistance(pos, trace.HitPos, 15) then
        return true
    else
        return false
    end
end

function Fuel:CanRefill(Machine, ply)
	if not IsValid(ply) then return false end
	if not ply:Alive() then return false end
	if not IsValid(Machine) then return false end
	if not ply:KeyDown(IN_USE) then return false end
	if not zpm.Machine.Fuel:OnButton(Machine, ply) then return false end
	if Machine:GetFuel() >= zpm.config.Machine.Fuel.Capacity then return false end
	if not zclib.Money.Has(ply, zpm.config.Machine.Fuel.Refill_Cost) then return false end

	return true
end

zpm.Machine.Fuel = Fuel
