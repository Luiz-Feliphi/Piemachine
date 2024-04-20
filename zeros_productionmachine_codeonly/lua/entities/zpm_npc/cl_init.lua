include("shared.lua")

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	zpm.HUD.Draw(self,50, function()
		draw.SimpleTextOutlined(self.PrintName, zclib.GetFont("zclib_world_font_big"), 0, 0, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black)
	end)
end
