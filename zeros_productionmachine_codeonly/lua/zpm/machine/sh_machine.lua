zpm = zpm or {}
zpm.Machine = zpm.Machine or {}


function zpm.Machine.OnInterface(Machine,ply,lpos)
	local trace = ply:GetEyeTrace()

	local pos = Machine:LocalToWorld(lpos)

    if zclib.util.InDistance(pos, trace.HitPos, 8) then
        return true
    else
        return false
    end
end

local LadderPos = Vector(-93,-88,57)
function zpm.Machine.OnLadderButton(Machine,ply)
	local trace = ply:GetEyeTrace()

	local pos = Machine:LocalToWorld(LadderPos)
    if zclib.util.InDistance(pos, trace.HitPos, 8) then
        return true
    else
        return false
    end
end


function zpm.Machine.CanChangeRecipie(Machine,ply)
	if not IsValid(Machine) then return false end
	if not IsValid(ply) then return false end

	if ply:IsSuperAdmin() then return true end

	// TODO We only want that superadmins can change the recipe of public entities?
end

function zpm.Machine.CanInteract(Machine,ply)
	if not IsValid(Machine) then return false end
	if not IsValid(ply) then return false end

	if ply:IsSuperAdmin() then return true end

	if Machine.IsPublicEntity then

		// Perform job check
		local ItemID = Machine:GetItemID()
		local ProductData = zpm.config.Items[ ItemID ]

		if ProductData and ProductData.jobs and table.Count(ProductData.jobs) > 0 then

			if ProductData.jobs[ply:Team()] then
				return true
			else
				return false , zpm.language["CantInteract_job"]
			end
		else
			// No Pie Recipe is currently selected, so i guess everyone can interact with the machine?
			return true
		end
	else
		// Is the player the owner of the machine or do we allow them to share their machine with other piemakers
		if not zclib.Player.IsOwner(ply, Machine) and not zpm.config.Machine.SharedEquipment then return false, zpm.language["CantInteract_owner"] end

	end

	return true
end
