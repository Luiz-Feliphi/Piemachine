zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

net.Receive("zpm.Machine.OpenInterface", function(len)
	zclib.Debug("zpm.Machine.OpenInterface Len: " .. len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	zpm.Machine.ProductionStatus(Machine,Machine:GetItemID())
end)

local WindowPnl
local function SimpleWindow(title,OnCreated)
	if IsValid(WindowPnl) then WindowPnl:Remove() end

	local mainframe = vgui.Create("DFrame")
	mainframe:SetSize(1000 * zclib.wM, 700 * zclib.hM)
	mainframe:Center()
	mainframe:MakePopup()
	mainframe:ShowCloseButton(false)
	mainframe:SetTitle("")
	mainframe:SetDraggable(true)
	mainframe:SetSizable(false)
	mainframe:DockPadding(0, 60 * zclib.hM,0,0)
	mainframe.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])

		draw.RoundedBox(5, 0, 0, w,  60 * zclib.hM, zclib.colors["black_a100"])
		draw.SimpleText(title, zclib.GetFont("zclib_font_big"), 30 * zclib.wM, 30 * zclib.hM, zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if input.IsKeyDown(KEY_ESCAPE) and IsValid(s) then
			s:Close()
		end
	end
	WindowPnl = mainframe

	local CloseBtn = vgui.Create("DButton", mainframe)
	CloseBtn:SetSize(60 * zclib.wM, 60 * zclib.hM)
	CloseBtn:SetPos(mainframe:GetWide() - 60 * zclib.wM,0 * zclib.hM)
	CloseBtn:SetText("")
	CloseBtn.Paint = function(s, w, h)
		surface.SetMaterial(zclib.Materials.Get("close"))
		surface.SetDrawColor(s:IsHovered() and zclib.colors["red01"] or zclib.colors["black_a100"])
		surface.DrawTexturedRect(0, 0, w,h)
	end
	CloseBtn.DoClick = function(s)
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		mainframe:Close()
	end

	pcall(OnCreated,mainframe)

	mainframe:Center()
end

local function AddPanel(parent,title,IsButton)
	local optionpnl = vgui.Create(IsButton and "DButton" or "DPanel", parent)
	optionpnl:Dock(FILL)
	optionpnl:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
	optionpnl:SetSize(500 * zclib.wM, 300 * zclib.hM)
	optionpnl:DockPadding(10 * zclib.wM, 40 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)
	if IsButton then optionpnl:SetText("") end
	optionpnl.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a100"])
		draw.RoundedBox(5, 0, 0, w, 30, zclib.colors["black_a50"])
		draw.SimpleText(title, zclib.GetFont("zclib_font_medium"), 8, 15, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	return optionpnl
end

local function BuildList(data)

	local content = AddPanel(data.parent,data.title)

	local list,scroll = zclib.vgui.List(content)
	list:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	scroll:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	scroll:Dock(FILL)
	scroll.Paint = function(s, w, h) end

	local ItemList = {}

	for k,v in pairs(data.ItemList) do

		if data.CanAdd and not data.CanAdd(k,v) then continue end

		table.insert(ItemList,{id = k,data = v})
	end

	local count = #ItemList
	if count < 6 then
		for i=1,(6 - count) do
			table.insert(ItemList,{})
		end
	end

	local ItemW, ItemH = 122, 122
	if #ItemList <= 6 then
		ItemW, ItemH = 130, 110
	end
	for _,dat in ipairs(ItemList) do
		local itm = list:Add("DPanel")
		itm:SetSize(ItemW * zclib.wM, ItemH * zclib.hM)
		itm.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a100"])
		end

		if not dat.id then continue end

		local name = data.GetItemName(dat.id,dat.data)
		local mdl = data.GetModel(dat.id,dat.data)
		local amount
		if data.GetItemAmount then
			amount = data.GetItemAmount(dat.id,dat.data)
		end

		local DisplayPanel = zclib.vgui.ModelPanel({model = mdl})
		DisplayPanel:SetParent(itm)
		DisplayPanel:Dock(FILL)
		DisplayPanel.PaintOver = function(s,w,h)
			draw.RoundedBox(5, 0, h * 0.8, w, h * 0.2, zclib.colors["black_a100"])
			draw.SimpleText(name, zclib.GetFont("zclib_font_small"), 5, h * 0.9, zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			if amount then
				draw.SimpleText(amount .. "x", zclib.GetFont("zclib_font_mediumsmall"), w - 5, 5, zclib.colors[ "text01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			end

			if data.PaintOver then
				pcall(data.PaintOver,dat,s,w,h)
			end
		end

		zpm.Item.ApplyVisuals(DisplayPanel.Entity,dat.id)

		if zpm.config.Items[dat.id].visual.color then
			DisplayPanel:SetColor(zpm.config.Items[dat.id].visual.color)
		end

		if data.OnClick then

			DisplayPanel.DoClick = function()
				zclib.vgui.PlaySound("UI/buttonclick.wav")
				data.OnClick(dat.id)
			end
		end
	end
end

function zpm.Machine.IngredientCheck(Machine,ItemID)
	Machine.zpm_MissingIngredeints = {}
	local ProductData = zpm.config.Items[ItemID]
	if not ProductData then return end
	if not ProductData.machine then return end
	if not ProductData.machine.ingredients then return end

	if not Machine.zclib_inv then return end

	local IngredientCount = {}
	for k,v in pairs(Machine.zclib_inv) do
		if not v then continue end
		if v.Class ~= "zpm_item" then continue end
		if not v.Data then continue end
		if not v.Data.ItemID then continue end
		IngredientCount[v.Data.ItemID] = (IngredientCount[v.Data.ItemID] or 0) + v.Amount
	end

	for id,am in pairs(ProductData.machine.ingredients) do
		Machine.zpm_MissingIngredeints[id]  = (IngredientCount[id] or 0) < am
	end
end

function zpm.Machine.ProductionStatus(Machine,ItemID)

	local ProductData = zpm.config.Items[ItemID]
	local ProductName = zpm.language["Selected Product"]
	if ProductData and ProductData.name then ProductName = ProductData.name end

	SimpleWindow(zpm.language["Machine"],function(main)


		local content = vgui.Create("DPanel", main)
		content:Dock(FILL)
		content:DockMargin(30 * zclib.wM, 20 * zclib.hM, 30 * zclib.wM, 10 * zclib.hM)
		content.Paint = function(s, w, h) end
		content:InvalidateLayout(true)
		content:InvalidateParent(true)

		local rpanel = vgui.Create("DPanel", content)
		rpanel:Dock(RIGHT)
		rpanel:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		rpanel:SetSize(500 * zclib.wM, 300 * zclib.hM)
		rpanel.Paint = function(s, w, h) end

		/*
			Setup inventory
		*/
		local invpnl = AddPanel(rpanel,zpm.language["Inventory"])
		invpnl:SetSize(500 * zclib.wM, 395 * zclib.hM)
		invpnl:Dock(TOP)
		invpnl:DockPadding(0 * zclib.wM, 40 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

		// This is needed since the inventory system refers to this
		zclib.vgui.ActiveEntity = Machine

		// This is needed by the inventory system since it would try to close this panel if we tried to place a item somewhere
		zclib_main_panel = main

        local inv = zclib.Inventory.VGUI({
            parent = invpnl,
            inv_ent = Machine,
            ExtraData = {
                SizeW = 88,
                SizeH = 77,
            },

            CanSelect = function(ItemData ,slot_data)
				return Machine:GetIsRunning()
			end,

            OnDragDrop = function(DragPanel,ReceiverPanel) end
        })
		inv:Dock(FILL)
		inv:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		inv.Paint = function(s, w, h) end
		inv.PaintOver = function(s, w, h)
			if not Machine:GetIsRunning() then
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a200" ])
				draw.SimpleText("Turn on the machine first", zclib.GetFont("zclib_font_medium"), w / 2, h / 2.2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("To use the Inventory", zclib.GetFont("zclib_font_medium"), w / 2, h / 1.8, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
		main.OnInventoryChanged = function()

			// Rebuild the interface
            zpm.Machine.ProductionStatus(Machine,ItemID)

			// Check if we are missing something for the current selected recipe
			zpm.Machine.IngredientCheck(Machine,ItemID)
        end
		zpm.Machine.IngredientCheck(Machine,ItemID)


		/*
			Setup option buttons
		*/
		local optionpnl = AddPanel(rpanel,zpm.language["Status"])
		local function AddBar(title,max,GetValue,PostDraw)
			local loadbar = vgui.Create("DPanel", optionpnl)
			loadbar:SetTall(40 * zclib.hM)
			loadbar:Dock(TOP)
			loadbar:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
			loadbar.Paint = function(s, w, h)
				if IsValid(Machine) then
					draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a50" ])

					local val = GetValue()

					local bar = (w / max) * val
					draw.RoundedBox(5, 0, h - (h * 0.2), w, h * 0.2, zclib.colors[ "black_a50" ])
					//draw.RoundedBox(5, 0, h - (h * 0.2), bar, h * 0.2, zclib.colors[ "green01" ])
					draw.RoundedBox(5, bar, h - (h * 0.2), 2, h * 0.2, color_white)

					draw.SimpleText(title, zclib.GetFont("zclib_font_small"),5, 5, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

					draw.SimpleText(val .. "%", zclib.GetFont("zclib_font_small"), w - 10, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

					if PostDraw then pcall(PostDraw,w,h) end
				end
			end
		end

		// Display the current cycle progress, (Each cycle will spawn new QTE which the player has to deal with in order to improve the Machines productivty)
		AddBar(zpm.language["Cycle"],zpm.config.Machine.CycleLength,function() return Machine:GetCycleProgress() end,function(w,h)
			//if not Machine:GetIsRunning() then return end

			if not Machine.QTE then return end

			for k, v in ipairs(Machine.QTE) do
				if not v.btnid then v.btnid = zpm.Machine.BoneDefinition[v.btn].tag.id end
				local pos = (w / zpm.config.Machine.CycleLength) * v.time

				local bWidth = (w / zpm.config.Machine.CycleLength) * zpm.config.Machine.QTE.Time

				surface.SetMaterial(zpm.Materials[ "btn_base" ])
				surface.SetDrawColor(Color(185, 185, 185))
				surface.DrawTexturedRect((bWidth / 2) + pos - 12, (h / 2) - 14, 24, 24)

				surface.SetMaterial(zpm.Materials[ "btn_hover" ])
				surface.SetDrawColor(Color(39, 127, 39))
				surface.DrawTexturedRect((bWidth / 2) + pos - 12, (h / 2) - 14, 24, 24)

				draw.SimpleText(v.btnid or "nil", zclib.GetFont("zclib_font_small"), (bWidth / 2) + pos, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.RoundedBox(0, pos - 1, h - (h * 0.2), bWidth, h * 0.2, zclib.colors[ "green01" ])
			end
		end)

		// Displays the progress of the product
		local ProgMax = 50
		if ProductData and ProductData.machine and ProductData.machine.time then
			ProgMax = ProductData.machine.time
		end
		AddBar(zpm.language["Progress"],ProgMax,function() return Machine:GetProductProgress() end)

		local btn = vgui.Create("DButton", optionpnl)
		btn:SetSize(60 * zclib.wM, 40 * zclib.hM)
		btn:Dock(TOP)
		btn:DockMargin(0 * zclib.wM, 10 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		btn:SetText("")
		btn.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a100" ])
			draw.SimpleText((Machine:GetIsRunning() and zpm.language[ "Stop" ] or zpm.language[ "Start" ]) .. " " .. zpm.language[ "Machine" ], zclib.GetFont("zclib_font_medium"), w / 2, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if Machine.NextMachineToggle and Machine.NextMachineToggle > CurTime() then
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "black_a100" ])
			end
		end
		btn.DoClick = function(s)

			if Machine:GetItemID() <= 0 then
				zclib.Notify(LocalPlayer(), zpm.language["NoProductSelected"], 1)
				return
			end


			// Check for fuel amount first
			if Machine:GetFuel() <= 0 then
				zclib.Notify(LocalPlayer(), zpm.language["NoFuel"], 1)
				return
			end

			if Machine.NextMachineToggle and CurTime() < Machine.NextMachineToggle then return end
			Machine.NextMachineToggle = CurTime() + 3

			zclib.vgui.PlaySound("UI/buttonclick.wav")

			net.Start("zpm.Machine.Toggle")
			net.WriteEntity(Machine)
			net.SendToServer()
		end

		/*
			Setup product panel
		*/
		local productpnl = AddPanel(content,ProductName,true)
		productpnl:Dock(TOP)
		productpnl:SetTall(300 * zclib.hM)
		productpnl.PaintOver = function(s, w, h)
			if not ProductData then
				draw.SimpleText("?", zclib.GetFont("zclib_font_giant"), w / 2, h / 1.8, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
		if ProductData then

			local DisplayPanel = zclib.vgui.ModelPanel({model = ProductData.visual.mdl,skin = ProductData.visual.skin or ProductData.ent.skin or 0})
			DisplayPanel:SetParent(productpnl)
			DisplayPanel:Dock(FILL)
			DisplayPanel:NoClipping(true)
			DisplayPanel.PaintOver = function(s, w, h)
				if s:IsHovered() then
					//draw.RoundedBox(5, 0, 0, w, h, zclib.colors[ "white_a5" ])
					//draw.RoundedBox(0, -10 * zclib.wM, h / 2 - 25, w + 20 * zclib.wM, 50, zclib.colors[ "black_a200" ])
					//draw.SimpleText(zpm.language["Change Recipe"], zclib.GetFont("zclib_font_big"), w / 2, h / 2, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					draw.SimpleText(" - "..zpm.language["Change Recipe"] .. " - ", zclib.GetFont("zclib_font_mediumsmall"), w / 2, h * 0.9, zclib.colors[ "green01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(" - "..zpm.language["Change Recipe"] .. " - ", zclib.GetFont("zclib_font_mediumsmall"), w / 2, h * 0.9, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			DisplayPanel.DoClick = function()
				zclib.vgui.PlaySound("UI/buttonclick.wav")

				net.Start("zpm.Machine.SelectProduct")
				net.WriteEntity(Machine)
				net.WriteUInt(0,10)
				net.SendToServer()

				zpm.Machine.ProductionStatus(Machine,0)
			end

			BuildList({
				parent = content,
				title = zpm.language["Ingredients"],
				ItemList = ProductData.machine.ingredients,
				CanAdd = function(id,data)
					local IngredientData = zpm.config.Items[id]
					if not IngredientData then return false end
					return true
				end,
				GetModel = function(id,data)
					return zpm.config.Items[id].visual.mdl
				end,
				GetItemName = function(id,product_amount)
					return zpm.config.Items[id].name
				end,
				GetItemAmount = function(id,product_amount)
					return product_amount
				end,
				PaintOver = function(data,pnl,w,h)
					if Machine.zpm_MissingIngredeints and Machine.zpm_MissingIngredeints[data.id] then
						local col = Color(255,0,0,15 * math.abs(math.sin(CurTime() * 3)) )
						//zclib.util.DrawOutlinedBox(0,0, w, h, 8, col )
						surface.SetDrawColor(col)
						surface.SetMaterial(zclib.Materials.Get("square_glow"))
						surface.DrawTexturedRect(0, 0, w, h)
					end
				end
			})
		else

			BuildList({
				parent = content,
				title = zpm.language["Recipies"],
				ItemList = zpm.config.Items,
				CanAdd = function(id,data)

					if not data.machine or not data.machine.ingredients then return false end

					if not zpm.Item.CanMake(id,LocalPlayer()) then return false end

					return true
				end,
				OnClick = function(id)
					net.Start("zpm.Machine.SelectProduct")
					net.WriteEntity(Machine)
					net.WriteUInt(id,10)
					net.SendToServer()
					zpm.Machine.ProductionStatus(Machine,id)
				end,
				GetModel = function(id,data)
					return data.visual.mdl
				end,
				GetItemName = function(id,data)
					return data.name
				end,
				PaintOver = function(data,pnl,w,h)
					if pnl:IsHovered() then
						draw.RoundedBox(5, 0, 0, w, h, zclib.colors["white_a15"])
					end
				end
			})
		end
	end)
end
