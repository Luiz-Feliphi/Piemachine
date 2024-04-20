zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

local Bone = zpm.Machine.Bone or {}

/*
	Rebuilds/Updates the bone position and angles of the machine
*/
function Bone:BuildPositions(Machine,numbones)

	for BoneID = 0, numbones - 1 do

		local bone_name = Machine:GetBoneName(BoneID)
		if not bone_name then continue end

		local def = zpm.Machine.BoneDefinition[bone_name]
		if not def then continue end

		if def.AnimateOnRun and Machine:GetIsRunning() then
			local rot = CurTime() * (45 * (def.Speed or 1))
			if def.Invert then rot = -rot end
			if def.ang then
				Machine:ManipulateBoneAngles(BoneID,Angle(def.ang.p * rot,def.ang.y * rot,def.ang.r * rot))
			else
				Machine:ManipulateBoneAngles(BoneID,Angle(0,rot,0))
			end
		end

		if def.AnimateAlways then
			local rot = CurTime() * 90
			if def.ang then
				Machine:ManipulateBoneAngles(BoneID,Angle(def.ang.p * rot,def.ang.y * rot,def.ang.r * rot))
			else
				Machine:ManipulateBoneAngles(BoneID,Angle(0,rot,0))
			end
		end

		local data = Machine.AnimatedBones[bone_name]
		if not data then continue end


		def = def.anim
		if not def then continue end

		if data.State ~= nil then

			if def.push_dir and def.push_dist then

				local dist = data.State and def.push_dist or 0

				if not Machine.SmoothBoneTranslations then Machine.SmoothBoneTranslations = {} end

				Machine.SmoothBoneTranslations[BoneID] = Lerp(FrameTime(),Machine.SmoothBoneTranslations[BoneID] or 0,dist)

				dist = Machine.SmoothBoneTranslations[BoneID]

				local BonePos , BoneAng = Machine:GetBonePosition(BoneID)

				local dir
				if def.push_dir.x > 0 then
					dir = BoneAng:Right() * dist
				elseif def.push_dir.y > 0 then
					dir = BoneAng:Up() * dist
				elseif def.push_dir.z > 0 then
					dir = BoneAng:Forward() * dist
				end

				local mat = Machine:GetBoneMatrix(BoneID)
				if not mat then continue end

				mat:SetTranslation(BonePos - dir)

				Machine:SetBoneMatrix(BoneID, mat)
			elseif def.switch_dir and def.switch_dist then

				local dist = data.State and def.switch_dist or 0

				if not Machine.SmoothBoneTranslations then Machine.SmoothBoneTranslations = {} end

				Machine.SmoothBoneTranslations[BoneID] = Lerp(FrameTime(),Machine.SmoothBoneTranslations[BoneID] or 0,dist)

				dist = Machine.SmoothBoneTranslations[BoneID]

				local BonePos , BoneAng = Machine:GetBonePosition(BoneID)

				local dir
				if def.switch_dir.x > 0 then
					dir = BoneAng:Right() * dist
				elseif def.switch_dir.y > 0 then
					dir = BoneAng:Up() * dist
				elseif def.switch_dir.z > 0 then
					dir = BoneAng:Forward() * dist
				end

				local mat = Machine:GetBoneMatrix(BoneID)
				if not mat then continue end

				mat:SetTranslation(BonePos - dir)

				Machine:SetBoneMatrix(BoneID, mat)
			elseif def.switch_ang and def.switch_dist then
				local rot = data.State and def.switch_dist or 0
				Machine.SmoothBoneTranslations[BoneID] = Lerp(FrameTime(),Machine.SmoothBoneTranslations[BoneID] or 0,rot)
				rot = Machine.SmoothBoneTranslations[BoneID]
				Machine:ManipulateBoneAngles(BoneID,Angle(def.switch_ang.p * rot,def.switch_ang.y * rot,def.switch_ang.r * rot))
			end
		end

		if data.Steer then
			local rot = data.Steer
			if def.ang then
				Machine.SmoothBoneTranslations[BoneID] = Lerp(FrameTime(),Machine.SmoothBoneTranslations[BoneID] or 0,rot)
				rot = Machine.SmoothBoneTranslations[BoneID]
				Machine:ManipulateBoneAngles(BoneID,Angle(def.ang.p * rot,def.ang.y * rot,def.ang.r * rot))
			else
				Machine.SmoothBoneTranslations[BoneID] = Lerp(FrameTime() * 5,Machine.SmoothBoneTranslations[BoneID] or 0,rot)
				rot = Machine.SmoothBoneTranslations[BoneID]
				Machine:ManipulateBoneAngles(BoneID,Angle(0,0,rot))
			end
		end
    end
end

zpm.Machine.Bone = Bone
