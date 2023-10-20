script_key="INPUT TOKEN HERE";
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pxsta72/ProjectAuto/main/paid"))()
local money = function(Hundreds)
	Hundreds=tonumber(Hundreds)
	local Million = 0
	local Thousand = 0
	local number = 0
	while Hundreds >= 1000 do
		Hundreds-=1000
		Thousand+=1
	end
	while Thousand >= 1000 do	
		Thousand-=1000
		Million+=1
	end
	if Million ~= 0 then number = string.format("$%s,%s,%s", Million, Thousand, Hundreds)
	else number = string.format("$%s,%s", Thousand, Hundreds)
	end
	return number
end
local plr = game:GetService("Players").LocalPlayer
request( { Url = 'INPUT WEBHOOK URL HERE', Method = 'POST', Headers = { ['Content-Type'] = 'application/json' }, Body = game:GetService('HttpService'):JSONEncode({content = 'Current money count: '..money(plr:WaitForChild("leaderstats").Money.Value)}) } );
queue_on_teleport('loadstring(game:HttpGet("THIS GITHUBS RAW LIKE HERE"))()')
