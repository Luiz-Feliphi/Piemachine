zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	The machine runs on fuel which need to be refilled after some time

*/

local Fuel = zpm.Machine.Fuel or {}

util.AddNetworkString("zpm.Machine.Refill")
function Fuel:Refill(Machine,ply)

	if not zpm.config.Machine.Fuel.enabled then return end

	local timerid = "zpm.Machine.Refill_" .. ply:SteamID()

	if not Fuel:CanRefill(Machine, ply) then

		if IsValid(ply) then ply.zpm_NextRefill = nil end

		timer.Remove(timerid)

		return false
	end

	timer.Remove(timerid)

	ply.zpm_NextRefill = CurTime() + zpm.config.Machine.Fuel.Refill_Time

	net.Start("zpm.Machine.Refill")
	net.WriteEntity(ply)
	net.WriteEntity(Machine)
	net.Broadcast()

	// Start the fuel refilling timer
	timer.Create(timerid, 0.1, 0, function()

		if not Fuel:CanRefill(Machine, ply) then
			if IsValid(ply) then ply.zpm_NextRefill = nil end
			timer.Remove(timerid)
			return
		end

		if ply.zpm_NextRefill then

			if CurTime() < ply.zpm_NextRefill then return end

			// Finish refilling
			Machine:SetFuel(math.Clamp(Machine:GetFuel() + zpm.config.Machine.Fuel.Refill_Amount,0,zpm.config.Machine.Fuel.Capacity))
			zclib.Money.Take(ply, zpm.config.Machine.Fuel.Refill_Cost)
			ply.zpm_NextRefill = nil

			return
		end

		// Start refilling
		ply.zpm_NextRefill = CurTime() + zpm.config.Machine.Fuel.Refill_Time
		net.Start("zpm.Machine.Refill")
		net.WriteEntity(ply)
		net.WriteEntity(Machine)
		net.Broadcast()
	end)

	return true
end

/*
	Check if we still got enough fuel
*/
function Fuel:Check(Machine)

	if not zpm.config.Machine.Fuel.enabled then return end

	if Machine.NextFuelUsage == nil or Machine.NextFuelUsage > 10 then
		Machine:SetFuel(math.Clamp(Machine:GetFuel() - 1,0,zpm.config.Machine.Fuel.Capacity))
		Machine.NextFuelUsage = 0
	end
	Machine.NextFuelUsage = (Machine.NextFuelUsage or 0) + 1
end

zpm.Machine.Fuel = Fuel
