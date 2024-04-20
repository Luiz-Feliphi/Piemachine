include("shared.lua")

function ENT:Initialize()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	zpm.HUD.Draw(self, self:GetModelRadius() * 1.5, function()
		draw.SimpleTextOutlined("x" .. self:GetItemAmount() .. " " .. zpm.Item.GetName(self:GetItemID()), zclib.GetFont("zclib_world_font_big"), 0, 0, zclib.colors[ "green01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
	end)
end
