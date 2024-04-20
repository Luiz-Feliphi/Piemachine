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
	Sets up everything needed for the Fuse events
*/
function Fuse:Setup(Machine)
	zclib.Debug("zpm.Machine.Fuse.Setup")

	Machine.FuseBox = {}
	for k, v in pairs(zpm.Machine.BoneDefinition) do
		if v and v.FuseBox then
			Machine.FuseBox[k] = zpm.config.Machine.FuseBox.Health
		end
	end
	if SERVER then
		zpm.Machine.Fuse:Update(Machine)
	end
end

-- This function checks if a player can fix a machine's fuse near a specific bone.
-- Parameters:
--  - Machine: The machine entity that needs fixing.
--  - ply: The player attempting to fix the machine.
--  - bone_name: The name of the bone where the fuse needs to be fixed.
-- Returns:
--  - A boolean indicating whether the player can fix the machine's fuse near the specified bone.
function Fuse:CanFix(Machine, ply, bone_name)

	-- Check if the player is valid and alive.
	if not IsValid(ply) then return false end
	if not ply:Alive() then return false end

	-- Check if the machine is valid.
	if not IsValid(Machine) then return false end

	-- Check if the player is pressing the use key.
	if not ply:KeyDown(IN_USE) then return false end

	-- Check if the machine has a fuse box.
	if not Machine.FuseBox then return false end

	-- Check if the specified bone has a fuse that needs fixing.
	if not Machine.FuseBox[ bone_name ] then return false end

	-- Check if the fuse in the specified bone has reached the maximum health level.
	if Machine.FuseBox[ bone_name ] >= zpm.config.Machine.FuseBox.Health then return false end

	-- Check if the player is still looking at the bone that needs fixing.
	local tr = ply:GetEyeTrace()
	if not tr or not tr.Hit or not tr.HitPos then return false end
	local bone_near = zpm.Machine.Button:GetNearest(Machine,tr.HitPos)

	-- Check if the nearest bone to the player's current view is the same as the one that needs fixing.
	if not bone_near then return false end
	if bone_near ~= bone_name then return false end

	-- Return true if all checks have passed.
	return true
end


zpm.Machine.Fuse = Fuse
