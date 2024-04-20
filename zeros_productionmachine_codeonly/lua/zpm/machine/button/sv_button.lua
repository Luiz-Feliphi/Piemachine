zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

local Button = zpm.Machine.Button or {}

/*
	Called when the player press the required button / lever / wheel on the machine
*/
util.AddNetworkString("zpm.Machine.Button.Press")
function Button:Press(Machine, ply)
	-- Get trace from player's view and return if not valid
	local tr = ply:GetEyeTrace()
	if not tr or not tr.Hit or not tr.HitPos then return end

	-- Get the nearest bone/button name to the trace hit position
	local bone_name = Button:GetNearest(Machine, tr.HitPos)
	if not bone_name then return end

	-- Get the bone data associated with the nearest bone/button
	local bone_data = zpm.Machine.BoneDefinition[bone_name]

	-- For certain buttons we want to block the press if a certain condition is not met
	if bone_data and bone_data.canpress and not bone_data.canpress(Machine, ply) then return end

	-- Get the ID of the nearest bone/button and return if not valid
	local bone_id = Machine:LookupBone(bone_name)
	if not bone_id then return end

	-- Send a network message to clients to animate this bone/button
	net.Start("zpm.Machine.Button.Press")
	net.WriteEntity(Machine)
	net.WriteUInt(bone_id, 16)
	net.Broadcast()
end

/*
	Here we figure out what button the player needs to press next
*/
function Button:GetNext(Machine)

	local list = {}
	for _,bone_data in pairs(zpm.Machine.SequencedBoneDefinition) do

		if not bone_data then continue end
		if not bone_data.anim then continue end

		// Only bones which have the QTE will be used
		if not bone_data.QTE then continue end

		table.insert(list,bone_data.bone_name)
	end

	return list[math.random(#list)]
end

zpm.Machine.Button = Button
