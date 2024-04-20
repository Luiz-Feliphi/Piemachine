zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	While the machine is producing something it will also create waste as a By-Product
	This waste needs to be cleaned away or it could start a dumpster fire which damages the machine and reduces the machines health

*/

local Waste = zpm.Machine.Waste or {}

util.AddNetworkString("zpm.Machine.ClearWaste")
function Waste:Clear(Machine,ply)

	if not zpm.config.Machine.Waste.enabled then return end

	if Machine.zpm_NextWasteClear and Machine.zpm_NextWasteClear > CurTime() then return false end

	if not Waste:CanClear(Machine, ply) then return false end

	Machine.zpm_NextWasteClear = CurTime() + 0.25

	Machine:SetWaste(math.Clamp(Machine:GetWaste() - zpm.config.Machine.Waste.Clear_Amount,0,zpm.config.Machine.Waste.Capacity))

	net.Start("zpm.Machine.ClearWaste")
	net.WriteEntity(Machine)
	net.Broadcast()

	return true
end

/*
	Check increased the waste and causes chaos if waste gets too much
*/
util.AddNetworkString("zpm.Machine.Waste.Explode")
function Waste:Check(Machine)

	if not zpm.config.Machine.Waste.enabled then return end

	if Machine.zpm_NextWasteIncrease and Machine.zpm_NextWasteIncrease > CurTime() then return false end
	Machine.zpm_NextWasteIncrease = CurTime() + zpm.config.Machine.Waste.Interval

	if not zpm.Machine.HasIngredients(Machine) then return end

	if Machine:GetWaste() >= zpm.config.Machine.Waste.Capacity then

		Machine:SetWaste(0)

		zpm.Machine.StopProduction(Machine)

		-- Trigger an explosion effect on the machine
		net.Start("zpm.Machine.Waste.Explode")
		net.WriteEntity(Machine)
		net.Broadcast()
	end

	Machine:SetWaste(math.Clamp(Machine:GetWaste() + zpm.config.Machine.Waste.Increase,0,zpm.config.Machine.Waste.Capacity))
end

zpm.Machine.Waste = Waste
