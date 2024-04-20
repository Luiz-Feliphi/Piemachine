zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	Quicktime Events requiere the player to press the correct button at the right time
	OnSuccess the machines productivity will increase
	OnFail the machines productivity will decrease

*/

local QTE = zpm.Machine.QTE or {}

net.Receive("zpm.Machine.QTE", function(len)
	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	Machine.QTE = {}
	local length = net.ReadUInt(10)

	Machine.QTE_Buttons = {}

	for i = 1,length do
		local time = net.ReadUInt(10)
		local button = net.ReadString()

		Machine.QTE_Buttons[button] = time

		Machine.QTE[i] = {
			time = time,
			btn = button
		}
	end
end)

zpm.Machine.QTE = QTE
