zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

local Button = zpm.Machine.Button or {}

/*
	Returns the button / bone name which is nearest to the provided location
*/
function Button:GetNearest(Machine,pos)
	-- Initialize variables to store nearest button/bone and distance
	local nearest, dist = nil, 9999999999999999999

	-- Loop through all bone definitions in the machine
	for _, bone_data in ipairs(zpm.Machine.SequencedBoneDefinition) do

		-- Skip if the bone data is not available or does not have an animation or is not a fusebox
		if not bone_data then continue end
		if not bone_data.anim and not bone_data.FuseBox then continue end

		local bone_name = bone_data.bone_name

		-- Get the ID of the bone and skip if not available
		local bone_id = Machine:LookupBone(bone_name)
		if not bone_id then continue end

		-- Get the position of the bone and skip if not available
		local bone_pos = zpm.Machine.Bone:GetPos(Machine, bone_id)
		if not bone_pos then continue end

		-- Calculate distance between the bone position and provided position
		local d = pos:Distance(bone_pos)

		-- Skip if distance is greater than 12
		if d > 12 then continue end

		-- If distance is less than current nearest distance, update nearest bone/button and distance
		if d < dist then
			nearest = bone_name
			dist = d
		end
	end

	-- Return the nearest bone/button name
	return nearest
end


zpm.Machine.Button = Button
