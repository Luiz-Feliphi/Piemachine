zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

local Bone = zpm.Machine.Bone or {}

/*
	Creates the value of each bone(lever / button) on the machine on both SERVER and CLIENT
*/
function Bone:SetupData(Machine)
	Machine.AnimatedBones = {}
	for k,v in pairs(zpm.Machine.BoneDefinition) do
		if not v or not v.anim then continue end
		Machine.AnimatedBones[k] = {}
		Machine.AnimatedBones[k].State = v.anim.State
		Machine.AnimatedBones[k].Steer = v.anim.Steer
	end
end

/*
	Here we setup everything requiered for bone animation
*/
function Bone:Setup(Machine)

	// Creates the value of each bone(lever / button) on the machine on both SERVER and CLIENT
	Bone:SetupData(Machine)

	if SERVER then return end

	Machine:InvalidateBoneCache()
	Machine:SetupBones()

	local CallBackID = Machine:AddCallback("BuildBonePositions", function(ent, numbones)
		Bone:BuildPositions(ent,numbones)
	end)

	Machine:CallOnRemove("Remove_BuildBonePositions_Callback_" .. math.random(99999999), function(ent)
		Machine:RemoveCallback("BuildBonePositions", CallBackID)
	end)
end

/*
	Returns the world position of the specified bone
*/
function Bone:GetPos(ent, bone_id)
	local bone_pos = ent:GetBonePosition(bone_id)
	if bone_pos == ent:GetPos() then
		local bone_name = ent:GetBoneName(bone_id)

		/*
			Returns a local position which can be used as a fallback value
			NOTE The reason behind this is that getting bone positions is a pain in the ass
		*/
		local fallback = zpm.Machine.BoneDefinition[bone_name].fallback
		if fallback then
			return ent:LocalToWorld(fallback)
		else
			return ent:GetBoneMatrix(bone_id):GetTranslation()
		end
	end
	return bone_pos
end

zpm.Machine.Bone = Bone
