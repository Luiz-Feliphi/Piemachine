zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

local Button = zpm.Machine.Button or {}

local function ChangeState(AnimB,time,Machine, bone_name,sound)
	if AnimB.State then return end
	zpm.Machine.PlaySoundAtBone(Machine, bone_name, sound)
	AnimB.State = true
	timer.Simple(time,function()
		AnimB.State = false
	end)
end
net.Receive("zpm.Machine.Button.Press", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	local bone_id = net.ReadUInt(16)
	if not bone_id then return end

	local bone_name = Machine:GetBoneName(bone_id)
	if not bone_name then return end

	local AnimB = Machine.AnimatedBones[bone_name]
	if not AnimB then return end

	local def = zpm.Machine.BoneDefinition[bone_name]

	if AnimB.State ~= nil then

		if def.anim.push_dist and not def.anim.IsLever then
			ChangeState(AnimB,0.5,Machine, bone_name, "buttons/button12.wav")
		else
			ChangeState(AnimB,0.3,Machine, bone_name, "buttons/lever7.wav")
		end
	elseif AnimB.Steer then
		AnimB.Steer = AnimB.Steer + 45

		zpm.Machine.PlaySoundAtBone(Machine, bone_name, "doors/door_squeek1.wav")
	end
end)

zpm.Machine.Button = Button
