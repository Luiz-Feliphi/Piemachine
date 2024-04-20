zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	The repair event will occure randomly and forces the player to fix the broken machine in a certain amount of time
	The repair minigame will be randomized

*/

local Repair = zpm.Machine.Repair or {}

/*
	Creates a new repair minigame
*/
function Repair:Setup(Machine)
	local order = zclib.table.randomize( {1,2,3} )

	Machine.Repair = {
		Start = CurTime(),
		Order = order,
		State = {
			[1] = false,
			[2] = false,
			[3] = false,
		}
	}
end

/*
	Creates a new repair minigame
*/
util.AddNetworkString("zpm.Machine.Repair.Start")
function Repair:Start(Machine)

	if not zpm.config.Machine.Repair.enabled then return end

	// Get a random button order which needs to be pressed
	Repair:Setup(Machine)

	Repair:Update(Machine)

	net.Start("zpm.Machine.Repair.Start")
	net.WriteEntity(Machine)
	net.Broadcast()

	Machine:SetNeedsRepair(true)
end

/*
	Sends the clients the list of buttons which are pressed / need to be pressed
*/
util.AddNetworkString("zpm.Machine.Repair.Update")
function Repair:Update(Machine)
	net.Start("zpm.Machine.Repair.Update")
	net.WriteEntity(Machine)
	net.WriteUInt(Machine.Repair.Start,32)
	for i = 1, 3 do net.WriteUInt(Machine.Repair.Order[ i ], 2) end
	for i = 1, 3 do net.WriteBool(Machine.Repair.State[ i ]) end
	net.Broadcast()
end

/*
	Called then the player interacts with the repair buttons
*/
function Repair:Interact(Machine,ply)

	if not zpm.config.Machine.Repair.enabled then return end

	if not Machine:GetNeedsRepair() then return end

	for i = 1, 3 do
		if zpm.Machine.Repair:OnButton(Machine, ply, i) then
			zpm.Machine.Repair:Solve(Machine, ply, i)
			return true
		end
	end
end

/*
    Gets called when the player presses one of the repair buttons.
*/
function Repair:Solve(Machine, ply, ButtonID)
    // If the repair interaction is blocked, do not proceed
    if Machine.BlockRepairInteraction and Machine.BlockRepairInteraction > CurTime() then
        return
    end

	if not Machine.Repair then return end

    // Check each expected button ID in the order they should be pressed
    for i, expectedButtonID in ipairs(Machine.Repair.Order) do

        // If the current button has not been pressed yet
        if not Machine.Repair.State[i] then

            // If the player pressed the expected button
            if ButtonID == expectedButtonID then

                // Mark the button as pressed and check if it was the last one
                Repair:CorrectButton(Machine, i)

                if i == 3 then

                    // If all buttons have been pressed, finish the repair after a delay
                    timer.Simple(1, function()
                        if IsValid(Machine) then
                            Repair:Finished(Machine)
                        end
                    end)

                    // Block the repair interaction for a few seconds
                    Machine.BlockRepairInteraction = CurTime() + 3
                end
            else
                // If the player pressed the wrong button, fail the repair
                Repair:Failed(Machine)
            end

            return
        end
    end
end

/*
	Called once we press the right button
*/
function Repair:CorrectButton(Machine,ButtonID)
	Machine.Repair.State[ButtonID] = true
	Machine:EmitSound("zpm_machine_rightbutton")
	Repair:Update(Machine)
end

/*
	If the player presses the wrong button then we fail the game
*/
util.AddNetworkString("zpm.Machine.Repair.Failed")
function Repair:Failed(Machine)
	Machine:SetNeedsRepair(false)

	zpm.Machine.DecreaseProductivity(Machine, zpm.config.Machine.Repair.ProductivityPenalty)

	net.Start("zpm.Machine.Repair.Failed")
	net.WriteEntity(Machine)
	net.Broadcast()
end

/*
	Called once the game is finished
*/
function Repair:Finished(Machine)
	Machine:SetNeedsRepair(false)
	Machine:EmitSound("zpm_machine_action_completed")
	zpm.Machine.IncreaseProductivity(Machine, zpm.config.Machine.Repair.ProductivityGain)
end

/*
	Returns the next repair event interval based on machine productivity and waste
*/
function Repair:GetInterval(Machine)

	-- Get the next repair interval and modify it by the interval_modify
    local next_interval = math.random(zpm.config.Machine.Repair.Interval.min, zpm.config.Machine.Repair.Interval.max)



    -- Get a value between 0 - 1 according to the machine's current productivity
    local productivity_scale = (1 / zpm.config.Machine.Productivity.max) * Machine:GetProductivity()

    -- Lerp between 1 and ProductivityPenalty depending on the machine's current productivity
    local interval_productivity_modify = Lerp(productivity_scale, 1, zpm.config.Machine.Repair.Interval.ProductivityPenalty)

	next_interval = next_interval * interval_productivity_modify



    -- The amount of trash that's not being cleared away will decrease the repair interval and the event will occur more often
    local waste_scale = (1 / zpm.config.Machine.Waste.Capacity) * Machine:GetWaste()

	-- Lerp between 1 and WastePenalty depending on the machine's current waste amount
    local interval_waste_modify = Lerp(waste_scale, 1, zpm.config.Machine.Repair.Interval.WastePenalty)

	next_interval = next_interval * interval_waste_modify



	local temp_scale = (1 / 35) * math.Clamp(Machine:GetTemperatur()-65,0,35)

	-- Lerp between 1 and WastePenalty depending on the machine's current temperatur
    local interval_temp_modify = Lerp(temp_scale, 1, zpm.config.Machine.Repair.Interval.TemperaturPenalty)

	next_interval = next_interval * interval_temp_modify


    return next_interval
end


/*
	Checks the state of the repair game
*/
function Repair:Check(Machine)

	if not zpm.config.Machine.Repair.enabled then return end

    -- Check if the machine needs repair
    if Machine:GetNeedsRepair() then

        -- If the repair timer has run out, the repair has failed
        if Machine.Repair and Machine.Repair.Start and CurTime() > (Machine.Repair.Start + zpm.config.Machine.Repair.Time) then
            Repair:Failed(Machine)
        end
    else

		if not zpm.Machine.HasIngredients(Machine) then return end

        -- If the machine doesn't need repair, check if it's time for the next repair event
        if not Machine.NextRepair then
            -- If there's no next repair event scheduled, schedule one
            Machine.NextRepair = CurTime() + Repair:GetInterval(Machine)
        else
            -- If there is a scheduled repair event, check if it's time to start it
            if CurTime() < Machine.NextRepair then return end

            -- Start the repair event
            Repair:Start(Machine)

            -- Schedule the next repair event
            Machine.NextRepair = CurTime() + Repair:GetInterval(Machine)
        end
    end
end


/*
	If the player presses the wrong button then we fail the game
*/
function Repair:Reset(Machine)
	Machine:SetNeedsRepair(false)
end

concommand.Add("zpm_debug_repair", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local ent = ents.FindByClass("zpm_machine")
		if ent and IsValid(ent[1]) then
			if ent[1]:GetNeedsRepair() then
				zpm.Machine.Repair:Finished(ent[1])
			else
				zpm.Machine.Repair:Start(ent[1])
			end

		end
	end
end)


zpm.Machine.Repair = Repair
