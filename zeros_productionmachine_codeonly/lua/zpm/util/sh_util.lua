zpm = zpm or {}

if SERVER then
	zclib.Player.CleanUp_Add("zpm_item")
	zclib.Player.CleanUp_Add("zpm_machine")
	zclib.Player.CleanUp_Add("zpm_buildkit")
	zclib.Player.CleanUp_Add("zpm_palette")
end

function zpm.Print(msg)
	print("[Zeros Productionmachine] " .. msg)
end
