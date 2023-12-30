if not CLIENT then return end
zpm = zpm or {}
zpm.Palette = zpm.Palette or {}

net.Receive("zpm_Palette_Update", function(len)
    local Palette = net.ReadEntity()
    local dataLength = net.ReadUInt(16)
    local dataDecompressed = util.Decompress(net.ReadData(dataLength))
    local ProductList = util.JSONToTable(dataDecompressed)

	Palette.ProductList = {}
    if ProductList and istable(ProductList) and IsValid(Palette) then
        Palette.ProductList = table.Copy(ProductList)

        Palette.UpdateClientProps = true
    end
end)

function zpm.Palette.Initialize(Palette)
    Palette.ProductList = {}

    Palette.Count_Y = 0
    Palette.Count_X = 0
    Palette.Count_Z = 0

    Palette.UpdateClientProps = false

    Palette.Money = zclib.Money.Display(0)
end

function zpm.Palette.Draw(Palette)
    if zclib.util.InDistance(Palette:GetPos(), LocalPlayer():GetPos(), 500)  then
        cam.Start3D2D(Palette:LocalToWorld(Vector(0, 0, 50 + 5 * Palette.Count_Z)), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
            local boxSize = zclib.util.GetTextSize(Palette.Money, zclib.GetFont("zclib_world_font_medium")) * 1.5
            draw.RoundedBox(0, -boxSize / 2, -30, boxSize, 60, zclib.colors["black_a100"])
            draw.SimpleText(Palette.Money, zclib.GetFont("zclib_world_font_medium"), 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            zclib.util.DrawOutlinedBox(-boxSize / 2, -30, boxSize, 60, 4, color_white)
        cam.End3D2D()
    end
end

function zpm.Palette.OnRemove(Palette)
    zpm.Palette.RemoveClientModels(Palette)
end

function zpm.Palette.Think(Palette)
    if zclib.util.InDistance(LocalPlayer():GetPos(), Palette:GetPos(), 1500) then
        if Palette.UpdateClientProps == true then

            // Calculates new money value
            local money = 0
            for k,v in pairs(Palette.ProductList) do
                money = money + zpm.Item.GetPrice(v)
            end

            Palette.Money = zclib.Money.Display(money)

            zpm.Palette.UpdateClientProps(Palette)

            Palette.UpdateClientProps = false
        end
    else
        zpm.Palette.RemoveClientModels(Palette)
        Palette.UpdateClientProps = true
    end
end

function zpm.Palette.UpdateClientProps(Palette)
    zpm.Palette.RemoveClientModels(Palette)

    Palette.ClientProps = {}

    for k, v in pairs(Palette.ProductList) do
        if not IsValid(Palette) then continue end
        if k == nil then continue end
        if v == nil then continue end
        zpm.Palette.CreateClientProp(Palette, k, v)
    end
end

function zpm.Palette.CreateClientProp(Palette, id, ItemID)

	local dat = zpm.config.Items[ItemID]
	if not dat then return end
	if not dat.visual then return end
	if not dat.visual.mdl then return end

    local pos = Palette:GetPos() - Palette:GetRight() * 25 - Palette:GetForward() * 33 + Palette:GetUp() * 6.3
    local ang = Palette:GetAngles() //Palette:LocalToWorldAngles(Angle(0,15 * id,0))


    if Palette.Count_X >= 3 then
        Palette.Count_X = 1
        Palette.Count_Y = Palette.Count_Y + 1
    else
        Palette.Count_X = Palette.Count_X + 1
    end

    if Palette.Count_Y >= 4 then
        Palette.Count_Y = 0
        Palette.Count_Z = Palette.Count_Z + 1
    end

    pos = pos + Palette:GetForward() * 17 * Palette.Count_X
    pos = pos + Palette:GetRight() * 17 * Palette.Count_Y
    pos = pos + (Palette:GetUp() * 6 * Palette.Count_Z)

    local crate = zclib.ClientModel.AddProp()
    if not IsValid(crate) then return end
    crate:SetAngles(ang)
    crate:SetModel(dat.visual.mdl)
    crate:SetPos(pos)

    crate:Spawn()
    crate:Activate()

    crate:SetRenderMode(RENDERMODE_NORMAL)
    crate:SetParent(Palette)

	local bound_min,bound_max = crate:GetModelBounds()
	local size = bound_max - bound_min
	size = size:Length()
	crate:SetModelScale(25 / size)

    Palette.ClientProps[id] = crate
end

function zpm.Palette.RemoveClientModels(Palette)
    Palette.Count_Y = 0
    Palette.Count_X = 0
    Palette.Count_Z = 0

    if (Palette.ClientProps and table.Count(Palette.ClientProps) > 0) then
        for k, v in pairs(Palette.ClientProps) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end

    Palette.ClientProps = {}
end
