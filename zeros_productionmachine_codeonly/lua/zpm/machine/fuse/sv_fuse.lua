zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	Sometimes a fuse will burnout in one of the fuseboxes
	Each fusebox has a bunch of fuses, if all fuses in one of the fuseboxes are burned out then the machine will shutdown
	The player needs to hold E in order to replace one of the fuses
	The Productivity of the machine will increase the burnout rate of the fuses

*/

local Fuse = zpm.Machine.Fuse or {}

/*
	Sends the state of all current FuseBoxes to the players
*/
util.AddNetworkString("zpm.Machine.Fuse.Update")
function Fuse:Update(Machine,bone_name)
	zclib.Debug("zpm.Machine.Fuse.Update")

	net.Start("zpm.Machine.Fuse.Update")
	net.WriteEntity(Machine)

	// The last fuse that broke
	net.WriteString(bone_name or "nil")

	net.WriteUInt(table.Count(Machine.FuseBox),10)
	for k,v in pairs(Machine.FuseBox) do
		net.WriteString(k)
		net.WriteUInt(v,10)
	end
	net.Broadcast()
end

function Fuse:Break(Machine)

	if not zpm.config.Machine.FuseBox.enabled then return end

	// Find random FuseBox and reduce 1 fuse
	local _,bone_name = table.Random(Machine.FuseBox)
	Machine.FuseBox[bone_name] = Machine.FuseBox[bone_name] - 1

	// Did we run out of fuses somewhere?
	if Machine.FuseBox[bone_name] <= 0 then

		// Shutdown!
		zpm.Machine.StopProduction(Machine)
	else

		// Update the clients about the current fuse state
		Fuse:Update(Machine,bone_name)
	end
end

/*
	Every second we will check if there is a QTE that has not been solved for in time
*/
function Fuse:Check(Machine)
	zclib.Debug("zpm.Machine.Fuse.Check")

	if not zpm.config.Machine.FuseBox.enabled then return end

	if not zpm.Machine.HasIngredients(Machine) then return end

	// Is it time for another Fuse event?
	if Machine.NextFuse and CurTime() > Machine.NextFuse then

		// Find random FuseBox and reduce 1 fuse
		Fuse:Break(Machine)
	end

	// Should we reset when the next Fuse event will occure?
	if not Machine.NextFuse or CurTime() > Machine.NextFuse then

		// Get a value between 0 - 1 according to the machines current productivity
		local productivity_scale = (1 / zpm.config.Machine.Productivity.max) * Machine:GetProductivity()

		// Lerp between 1 and ProductivityReduction depending on the machines current Productivity
		local lifetime_modify = Lerp(productivity_scale, 1, zpm.config.Machine.FuseBox.Lifetime.ProductivityReduction)

		// Get the next burnout time of a fuse and modify it by the lifetime_modify
		local next_lifetime = math.random(zpm.config.Machine.FuseBox.Lifetime.min, zpm.config.Machine.FuseBox.Lifetime.max) * lifetime_modify

		Machine.NextFuse = CurTime() + next_lifetime
	end
end

/*
	Called when a player presses a button
*/
util.AddNetworkString("zpm.Machine.Fuse.Interact")
-- This function allows a player to interact with a machine's fuse in their current view.
-- Parameters:
--  - Machine: The machine entity that the player wants to interact with.
--  - ply: The player who wants to interact with the machine.
-- Returns:
--  - A boolean indicating whether the interaction was successful or not.
function Fuse:Interact(Machine,ply)

	if not zpm.config.Machine.FuseBox.enabled then return end

	-- Debugging statement.
	zclib.Debug("zpm.Machine.Fuse.Interact")

	-- Get the trace of the player's view.
	local tr = ply:GetEyeTrace()
	if not tr or not tr.Hit or not tr.HitPos then return end

	-- Get the name of the nearest bone to the player's view.
	local bone_name = zpm.Machine.Button:GetNearest(Machine,tr.HitPos)
	if not bone_name then return end

	-- Create a unique timer ID for the interaction.
	local timerid = "zpm.Machine.Fuse.Interact_" .. ply:SteamID()

	-- Check if the player can fix the fuse in the current bone.
	if not Fuse:CanFix(Machine, ply,bone_name) then
		-- Reset the player's fuse fixing timer and remove the timer associated with this interaction.
		if IsValid(ply) then ply.zpm_NextFuseFix = nil end
		timer.Remove(timerid)
		return false
	end
	timer.Remove(timerid)

	-- Set the player's next fuse fixing time.
	ply.zpm_NextFuseFix = CurTime() + zpm.config.Machine.FuseBox.Time

	-- Send a network message to the player to start the fuse fixing animation.
	net.Start("zpm.Machine.Fuse.Interact")
	net.WriteEntity(Machine)
	net.WriteString(bone_name)
	net.Send(ply)

	-- Start a timer to handle the fuse fixing progress.
	timer.Create(timerid, 0.1, 0, function()

		-- Check if the player can still fix the fuse in the current bone.
		if not Fuse:CanFix(Machine, ply, bone_name) then
			-- Reset the player's fuse fixing timer and remove the timer associated with this interaction.
			if IsValid(ply) then ply.zpm_NextFuseFix = nil end
			timer.Remove(timerid)
			return
		end

		-- Check if the player has finished fixing the fuse.
		if ply.zpm_NextFuseFix then

			if CurTime() < ply.zpm_NextFuseFix then return end

			-- The fuse fixing is complete.
			Fuse:Solved(Machine, bone_name)
			ply.zpm_NextFuseFix = nil

			return
		end

		-- The fuse fixing has just started.
		ply.zpm_NextFuseFix = CurTime() + zpm.config.Machine.FuseBox.Time
		net.Start("zpm.Machine.Fuse.Interact")
		net.WriteEntity(Machine)
		net.WriteString(bone_name)
		net.Send(ply)
	end)

	return true
end


/*
	Called when a FuseBox event got solved
*/
function Fuse:Solved(Machine, bone)
	zclib.Debug("zpm.Machine.Fuse.Solved")

	//Machine:EmitSound("zpm_machine_rightbutton")

	// {{ user_id | 76561197999833630 }}
	Machine.FuseBox[bone] = math.Clamp(Machine.FuseBox[bone] + 1,0,zpm.config.Machine.FuseBox.Health)

	Fuse:Update(Machine)
end

zpm.Machine.Fuse = Fuse
