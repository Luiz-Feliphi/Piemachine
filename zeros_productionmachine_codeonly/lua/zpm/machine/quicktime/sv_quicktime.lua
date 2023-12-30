zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	Quicktime Events requiere the player to press the correct button at the right time
	OnSuccess the machines productivity will increase
	OnFail the machines productivity will decrease

*/

local QTE = zpm.Machine.QTE or {}

/*
	Sends all the curretn QTEs to the players
*/
util.AddNetworkString("zpm.Machine.QTE")
function QTE:Update(Machine)
	zclib.Debug("zpm.Machine.QTE.Update")

	Machine.QTE = Machine.QTE or {}

	net.Start("zpm.Machine.QTE")
	net.WriteEntity(Machine)
	net.WriteUInt(#Machine.QTE,10)
	for k,v in ipairs(Machine.QTE) do
		net.WriteUInt(v.time,10)
		net.WriteString(v.btn)
	end
	net.Broadcast()
end

/*
	Here we create a bunch of Quicktime events which occur at certain times in the zpm.config.Machine.CycleLength second cycle
*/
function QTE:Create(Machine)
	zclib.Debug("zpm.Machine.QTE.Create")

	Machine.QTE = {}

	local function AddQTE(time)
		local btn = zpm.Machine.Button:GetNext(Machine)

		table.insert(Machine.QTE,{

			// At which point in the zpm.config.Machine.CycleLength second cycle will the QTE Occure?
			time = time,

			// What button needs to be pressed?
			btn = btn
		})
	end

	if math.random(10) > 5 then
		AddQTE(zpm.config.Machine.CycleLength * 0.1)
	end

	if Machine:GetProductivity() >= (zpm.config.Machine.Productivity.max * 0.3) and math.random(10) > 5 then
		AddQTE(zpm.config.Machine.CycleLength * 0.5)
	end

	if Machine:GetProductivity() >= (zpm.config.Machine.Productivity.max * 0.6) and math.random(10) > 5 then
		AddQTE(zpm.config.Machine.CycleLength * 0.75)
	end

	QTE:Update(Machine)
end

/*
	Every second we will check if there is a QTE that has not been solved for in time
*/
function QTE:Check(Machine)
	if not Machine.QTE then return end

	for k,qte in ipairs(Machine.QTE) do
		if qte.solved then continue end

		if Machine:GetCycleProgress() > (qte.time + zpm.config.Machine.QTE.Time) then
			QTE:Failed(Machine,k)
		end
	end
end

function QTE:CorrectButton(Machine,bone_name)
	local CorrectButton

	for k,qte in ipairs(Machine.QTE) do

		if qte.btn ~= bone_name then continue end

		if Machine:GetCycleProgress() >= qte.time then

			QTE:Solved(Machine,k)

			CorrectButton = true
			break
		end
	end
	return CorrectButton
end

/*
	Called when a player presses a button
*/
function QTE:Interact(Machine,ply)

	// Get the position of the player's eye trace
	local tr = ply:GetEyeTrace()

	// Check if the eye trace hit something valid, if not then return
	if not tr or not tr.Hit or not tr.HitPos then return end

	// Get the name of the nearest button to the player's eye trace hit position
	local bone_name = zpm.Machine.Button:GetNearest(Machine,tr.HitPos)

	// If there is no nearest button, then return
	if not bone_name then return end

	// Check if the nearest button has a QTE sequence associated with it, if not then return
	if not zpm.Machine.BoneDefinition[bone_name].QTE then return end

	// Check if the button pressed was the correct button for the QTE sequence, if it was then return true
	if QTE:CorrectButton(Machine,bone_name) then return true end

	// Check if there is a wrong button penalty defined, if not then return
	if not zpm.config.Machine.QTE.WrongButtonPenalty or zpm.config.Machine.QTE.WrongButtonPenalty <= 0 then return end

	// Check if the machine is currently running, if not then return
	if not Machine:GetIsRunning() then return end

	// Decrease productivity of the machine since the wrong button was pressed
	zpm.Machine.DecreaseProductivity(Machine, zpm.config.Machine.QTE.WrongButtonPenalty)
end

/*
	Called when a quicktime event got failed
*/
function QTE:Failed(Machine,id)
	Machine.QTE[id] = nil

	zpm.Machine.DecreaseProductivity(Machine, zpm.config.Machine.QTE.ProductivityPenalty)

	Machine:EmitSound("zpm_machine_action_failed")

	// Break a fuse somehwere
	timer.Simple(1.5, function() if IsValid(Machine) then zpm.Machine.Fuse:Break(Machine) end end)

	// {{ user_id | 76561197999833630 }}
	QTE:Update(Machine)
end

/*
	Called when a quicktime event got solved
*/
function QTE:Solved(Machine, id)

	Machine:EmitSound("zpm_machine_rightbutton")

	timer.Simple(1.5,function() if IsValid(Machine) then Machine:EmitSound("zpm_machine_action_completed") end end)

	table.remove(Machine.QTE,id)

	zpm.Machine.IncreaseProductivity(Machine, zpm.config.Machine.QTE.ProductivityGain)

	QTE:Update(Machine)
end

zpm.Machine.QTE = QTE
