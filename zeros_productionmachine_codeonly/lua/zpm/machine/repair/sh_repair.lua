zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	The repair event will occure randomly and forces the player to fix the broken machine in a certain amount of time
	The repair minigame will be randomized

*/

-- Define the Repair sub-table if it doesn't already exist.
-- This sub-table will contain functions related to the machine repair event and minigame.
local Repair = zpm.Machine.Repair or {}

-- The positions of the buttons that the player needs to click during the repair minigame.
Repair.ButtonPositions = {
	["exit_top_bt01_jnt"] = 1,
	["exit_top_bt02_jnt"] = 2,
	["exit_top_bt03_jnt"] = 3,
}

-- Check if the player is aiming at the correct button.
-- Returns true if the player is aiming at the button, false otherwise.
function Repair:OnButton(Machine, ply, ButtonID)

	// Get the position of the player's eye trace
	local tr = ply:GetEyeTrace()

	// Check if the eye trace hit something valid, if not then return
	if not tr or not tr.Hit or not tr.HitPos then return end

	// Get the name of the nearest button to the player's eye trace hit position
	local bone_name = zpm.Machine.Button:GetNearest(Machine,tr.HitPos)

	// If there is no nearest button, then return
	if not bone_name then return end

	if not Repair.ButtonPositions[bone_name] then return end

	if Repair.ButtonPositions[bone_name] == ButtonID then return true end
end

-- Set the zpm.Machine.Repair table to the Repair table we just defined.
zpm.Machine.Repair = Repair
