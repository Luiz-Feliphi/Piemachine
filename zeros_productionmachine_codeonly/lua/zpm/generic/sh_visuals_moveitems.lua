zpm = zpm or {}
zpm.ItemMove = zpm.ItemMove or {}
zpm.ItemMove.TasksQueu = zpm.ItemMove.TasksQueu or {}
zpm.ItemMove.Tasks = zpm.ItemMove.Tasks or {}

/*

	Here we handle all the visual stuff about ingredients being added to the machine via conveyrail to the shaft

*/

zpm.ItemMove.Paths = {
	["InsertRail"] = {
		StartPos = Vector(159, 57.8, 62),
		EndPos = Vector(27, 57.8, 62),
		Next = "InsertDrop",
		speed = 0.65,
		effects = true,
	},
	["InsertDrop"] = {
		StartPos = Vector(27, 57.8, 62),
		EndPos = Vector(27.5, 60, 25),
		IsFalling = true,
		speed = 3,
		effects = true,
	},

	["ConveyBelt"] = {
		StartPos = Vector(27, 10, 68),
		EndPos = Vector(27, 57, 96),
		Next = "ConveyDrop",
		speed = 0.35
	},
	["ConveyDrop"] = {
		StartPos = Vector(27, 60, 96),
		EndPos = Vector(27.5, 60, 25),
		IsFalling = true,
		speed = 2,
		effects = true,
	},
}

if SERVER then

	concommand.Add("zpm_moveitems_test", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
			if tr and tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zpm_machine" then
				//zpm.ItemMove.Create(tr.Entity,4,10,"ConveyBelt")

				for p_id,p_amount in pairs(zpm.config.Items[ZPM_ITEM_APPLEPIE].machine.ingredients) do
					zpm.ItemMove.Create(tr.Entity,p_id,p_amount * 15,"ConveyBelt")
				end
			end
		end
	end)

	/*
		Tells the clients to create a 3d dummy object that moves in to the machine
	*/
	util.AddNetworkString("zpm.ItemMove.Create")
	function zpm.ItemMove.Create(Machine,ItemID,ItemAmount,PathID)

		// Doesent need to be that much
		ItemAmount = math.Clamp(ItemAmount,1,3)

		net.Start("zpm.ItemMove.Create")
		net.WriteEntity(Machine)
		net.WriteUInt(ItemID,10)
		net.WriteUInt(ItemAmount,12)
		net.WriteString(PathID)
		net.Broadcast()
	end
else

	/*
		Small utility function to create a lua emitter particle explosion
	*/
	local gravity = Vector(0, 0, -500)
	local function ParticleExplosion(pos,color,EffectType)
		local emitter = ParticleEmitter( pos , false )
		if not emitter or not emitter:IsValid() then return end

		local scale, count, resistance, texture , rndAng
		if EffectType == "liquid" then
			scale = 1
			count = 10
			resistance = 1500
			texture = "zerochain/zpm/particle/liquid_bubble01"
		else
			scale = 2
			count = 10
			resistance = 1500
			texture = "zerochain/zpm/particle/sand01"
			rndAng = true
		end

		for i = 1,count do
			local particle = emitter:Add(texture, pos + VectorRand(-1,1))

			if rndAng then particle:SetAngles(AngleRand()) end

			particle:SetVelocity(VectorRand(-50,50))

			particle:SetDieTime(math.Rand(0.2,1))
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)

			particle:SetStartSize(scale * math.Rand(1, 1.5))
			particle:SetEndSize(0)

			particle:SetCollide(false)
			particle:SetColor(color.r,color.g,color.b)

			particle:SetGravity(gravity)
			particle:SetAirResistance(resistance)
		end

		emitter:Finish()
	end

	local function GetTravelTime(pos01,pos2,speed)
	    local time = pos01:Distance(pos2)

	    time = time / 25

	    // Gets the speed
	    local Speed = speed

	    // Apply speed according to Machine upgrade
	    time = time / Speed

	    return time
	end

	local function CreateClientModel(model,pos)
		local ent = ents.CreateClientProp()

		// Just to make sure we dont cause a crash
		if not IsValid(ent) then return end
		if not ent:IsValid() then return end
		if not ent.SetModel then return end

		// Lets cache the model now
		zclib.CacheModel(model)

		ent:SetPos(pos)
		ent:SetModel(model)
		ent:SetAngles(angle_zero)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	net.Receive("zpm.ItemMove.Create", function(len,ply)
		zclib.Debug_Net("zpm.ItemMove.Create",len)

	    local Machine = net.ReadEntity()
		if not IsValid(Machine) then return end

		local ItemID = net.ReadUInt(10)
		if not ItemID then return end

		local ItemAmount = net.ReadUInt(12)
		if not ItemAmount then return end

		local PathID = net.ReadString()
		if not PathID then return end

		for i = 1, ItemAmount do
			table.insert(zpm.ItemMove.TasksQueu,{
				Machine = Machine,
				ItemID = ItemID,
				PathID = PathID,
			})
		end
	end)

	function zpm.ItemMove.Create(Machine,ItemID,PathID,MoveOffset)
		if not IsValid(Machine) then return end
		if not Machine:GetIsRunning() then return end
		local PathData = zpm.ItemMove.Paths[PathID]
		if not PathData then return end

		// PathData.IsFalling and 2 or 0.65
		local duration = GetTravelTime(Machine:LocalToWorld(PathData.StartPos), Machine:LocalToWorld(PathData.EndPos), PathData.speed)

		if PathID == "InsertRail" then
			Machine.RailInsertion = CurTime() + duration
		end

		local data = {
			// What are we taking?
			PathID = PathID,

			// What item are we moving
			ItemID = ItemID,

			// When did we start moving?
			StartTime = CurTime(),

			// How long will the item move
			TravelTime = duration,

			// Where does the item spawn from (LocalVector)
			StartPos = PathData.StartPos,

			// Where should the item move to (LocalVector)
			EndPos = PathData.EndPos,

			// The machine
			Machine = Machine,

			// How should the item be rotated
			LocalAngle = PathData.LocalAngle,

			// Should the item angle change over time?
			IsFalling = PathData.IsFalling,

			// The offset angle for this item
			UniqueID = math.random(99999999),

			// If we got a MoveOffset from a previous item then use it for the next path
			MoveOffset = MoveOffset,
		}

        table.insert(zpm.ItemMove.Tasks,data)
    end

    // Handels the Unit movement
    function zpm.ItemMove.Logic(data)
        if not data.StartPos then return end
        if not data.EndPos then return end

		local ItemData = zpm.config.Items[data.ItemID]
		if not ItemData then return end
		if not ItemData.visual then return end
		if not ItemData.visual.mdl then return end

		local PathData = zpm.ItemMove.Paths[data.PathID]
		if not PathData then return end

        if IsValid(data.DummyEnt) then

            local dest_time = data.StartTime + data.TravelTime

            local time_dif = math.Clamp(dest_time - CurTime(),0,100)

            local fract = math.Clamp((1 / data.TravelTime) * time_dif, 0, 1)
            fract = 1 - fract

			local startPos, endPos = data.StartPos , data.EndPos

			if ItemData.visual.mover_effect and PathData.effects and (not data.NextEffect or (data.NextEffect and CurTime() > data.NextEffect)) then
				ParticleExplosion(data.DummyEnt:GetPos(),ItemData.visual.color or color_white, ItemData.visual.mover_effect)
				data.NextEffect = CurTime() + 0.1
			end


			if data.PathID == "ConveyBelt" then

				// If the path is along a belt then randomize the items X position a bit
				if not data.MoveOffset then data.MoveOffset = Vector(math.random(-5,5),0,0) end

				// Also allign the model to the path direction
				if not data.AngleOffset then
					local path = zpm.ItemMove.Paths[ "ConveyBelt" ]
					data.AngleOffset = (path.StartPos - path.EndPos):Angle()
				end
			end


			// Apply the random X position on the start position
			if data.MoveOffset then startPos = startPos + data.MoveOffset end

			// Apply the random end pos to the end pos
			//if data.RandomEndPos then endPos = endPos + data.RandomEndPos end

			// Apply the random X position on the end position
			if data.MoveOffset then endPos = endPos + data.MoveOffset end

			// Convert to world positions
			startPos = data.Machine:LocalToWorld(startPos)
			endPos = data.Machine:LocalToWorld(endPos)


            local _pos = LerpVector(fract, startPos,endPos)

			if data.IsFalling then
				local ang = CurTime() * 600
				data.DummyEnt:SetAngles(data.Machine:LocalToWorldAngles(Angle((ang / 2) + data.UniqueID, ang + data.UniqueID, (ang / 4) + data.UniqueID)))
			else
				local ang = data.LocalAngle or angle_zero

				if data.InitialRotation then
					local o = data.InitialRotation
					ang = Angle(ang.p + o.p, ang.y + o.y, ang.r + o.r)
				end

				if ItemData.visual.mover_offset_rot then
					local o = ItemData.visual.mover_offset_rot
					ang = Angle(ang.p + o.p, ang.y + o.y, ang.r + o.r)
				end

				if data.AngleOffset then
					local o = data.AngleOffset
					ang = Angle(ang.p + o.p, ang.y + o.y, ang.r + o.r)
				end

				data.DummyEnt:SetAngles(data.Machine:LocalToWorldAngles(ang))
			end

			if IsValid(data.ClamperEnt) then
				data.DummyEnt:SetPos(_pos - data.DummyEnt:OBBCenter() - data.Machine:GetRight() * 3)

				data.ClamperEnt:SetPos(_pos)
				data.ClamperEnt:SetAngles(data.Machine:LocalToWorldAngles(angle_zero))
			else
				data.DummyEnt:SetPos(_pos - data.DummyEnt:OBBCenter())
			end
        else

			if ItemData.visual.mover_init_rot_rnd then
				data.InitialRotation = AngleRand()
			end

			if data.PathID == "InsertRail" then
				data.ClamperEnt = CreateClientModel("models/zerochain/props_animalfarm/zafa_piemachine_clamper.mdl",data.Machine:LocalToWorld(data.StartPos))
			end

            data.DummyEnt = CreateClientModel(ItemData.visual.mdl,data.Machine:LocalToWorld(data.StartPos))

			zpm.Item.ApplyVisuals(data.DummyEnt,data.ItemID)

            // Scale model so they are allways the same scale no matter what
            local bound_min,bound_max = data.DummyEnt:GetModelBounds()
            local size = bound_max - bound_min
            size = size:Length()
            local scale = 7 / size

			if ItemData.visual.mover_offset_scale then
				scale = scale * ItemData.visual.mover_offset_scale
			end

            data.DummyEnt:SetModelScale(scale)
        end
    end

    function zpm.ItemMove.KillTask(id)
        local data = zpm.ItemMove.Tasks[id]

		if data then
			if IsValid(data.DummyEnt) then
	            SafeRemoveEntity(data.DummyEnt)
	        end

			if IsValid(data.ClamperEnt) then
				SafeRemoveEntity(data.ClamperEnt)
			end

			if (data.PathID == "InsertDrop" or data.PathID == "ConveyDrop") and IsValid(data.Machine) then

				local ItemData = zpm.config.Items[data.ItemID]
				if ItemData and ItemData.visual and ItemData.visual.mover_sound then
					zclib.Sound.EmitFromPosition(data.Machine:LocalToWorld(zpm.ItemMove.Paths["InsertDrop"].EndPos),ItemData.visual.mover_sound)
				end

				zclib.Sound.EmitFromPosition(data.Machine:LocalToWorld(zpm.ItemMove.Paths["InsertDrop"].EndPos),"zpm_machine_item_drop_metal")
			end

			if data.PathID == "InsertRail" and IsValid(data.Machine) then
				zclib.Sound.EmitFromPosition(data.Machine:LocalToWorld(zpm.ItemMove.Paths["InsertRail"].EndPos),"zpm_machine_rail_clamp_open")
			end


			if data.StartTime and data.TravelTime and (data.StartTime + data.TravelTime) < CurTime() and data.PathID then
				local PathData = zpm.ItemMove.Paths[data.PathID]
				if PathData and PathData.Next then
					zpm.ItemMove.Create(data.Machine,data.ItemID,PathData.Next,data.MoveOffset)
				end
			end
		end

		table.remove(zpm.ItemMove.Tasks,id)
        //zpm.ItemMove.Tasks[id] = nil
    end

	local NextDelay = 0
	zclib.Hook.Add("Think", "MoveItems", function()
		if CurTime() > NextDelay then
			local data = zpm.ItemMove.TasksQueu[ 1 ]

			if data then
				local SpawnDelay = data.PathID == "ConveyBelt" and 0.3 or 0.7
				zpm.ItemMove.Create(data.Machine, data.ItemID, data.PathID)
				table.remove(zpm.ItemMove.TasksQueu, 1)
				NextDelay = CurTime() + SpawnDelay
			end
		end

		for key, data in ipairs(zpm.ItemMove.Tasks) do
			if not IsValid(data.Machine) then
				zpm.ItemMove.KillTask(key)
				continue
			end

			if not data.Machine:GetIsRunning() then
				zpm.ItemMove.KillTask(key)
				continue
			end

			if data == nil then
				zpm.ItemMove.KillTask(key)
				continue
			end

			if data.StartPos == nil then
				zpm.ItemMove.KillTask(key)
				continue
			end

			if data.EndPos == nil then
				zpm.ItemMove.KillTask(key)
				continue
			end

			if IsValid(data.Machine) and not zclib.util.InDistance(LocalPlayer():GetPos(), data.Machine:GetPos(), 3000) then
				if IsValid(data.DummyEnt) then
					SafeRemoveEntity(data.DummyEnt)
				end

				if IsValid(data.ClamperEnt) then
					SafeRemoveEntity(data.ClamperEnt)
				end

				continue
			end

			if (data.StartTime + data.TravelTime) > CurTime() then
				zpm.ItemMove.Logic(data)
			else
				zpm.ItemMove.KillTask(key)
			end
		end
	end)
end
