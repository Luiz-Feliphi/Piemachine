zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	Quicktime Events requiere the player to press the correct button at the right time
	OnSuccess the machines productivity will increase
	OnFail the machines productivity will decrease

*/

local QTE = zpm.Machine.QTE or {}

/*
	Sets up everything needed for the Quicktime events
*/
function QTE:Setup(Machine)
	Machine.QTE = {}
	if SERVER then QTE:Update(Machine) end
end

zpm.Machine.QTE = QTE
