zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	While the machine is producing something it will also create waste as a By-Product
	This waste needs to be cleaned away or it could start a dumpster fire which damages the machine and reduces the machines health

*/

local Waste = zpm.Machine.Waste or {}

local waste_pos = Vector(-181, -39, 39)
function Waste:OnButton(Machine,ply)
	local trace = ply:GetEyeTrace()

	local pos = Machine:LocalToWorld(waste_pos)
    if zclib.util.InDistance(pos, trace.HitPos, 15) then
        return true
    else
        return false
    end
end

function Waste:CanClear(Machine, ply)
	if not IsValid(ply) then return false end
	if not ply:Alive() then return false end
	if not IsValid(Machine) then return false end
	if not ply:KeyDown(IN_USE) then return false end
	if not Waste:OnButton(Machine, ply) then return false end
	if Machine:GetWaste() <= 0 then return false end

	return true
end

zpm.Machine.Waste = Waste
