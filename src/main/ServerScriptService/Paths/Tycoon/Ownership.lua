local Ownership = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services


--- Ownership Variables
function Ownership:GetOwner(Tycoon)
	return workspace.Tycoons[Tycoon].Owner.Value
end

function Ownership:IsOwner(Tycoon, Player)
	return 
end

function Ownership:GetPlayerTycoon(Player)
	local TycoonName = Player:GetAttribute("Tycoon")
	return if TycoonName then workspace.Tycoons:FindFirstChild(TycoonName) else nil
end

function Ownership:ClaimTycoon(Tycoon, Player)
	local Tycoon = workspace.Tycoons[Tycoon]
	if Tycoon.Owner.Value == "None" then
		Tycoon.Owner.Value = Player.Name
		Player:SetAttribute("Tycoon", Tycoon.Name)
		Player.Team = Services.Teams[Tycoon.Name.." Island"]
	else
		warn(Player, "was kicked due to Tycoon already being claimed")
		Player:Kick("Tycoon Loading Error: Please try rejoining!")
	end
end

function Ownership:UnclaimTycoon(Tycoon)
	if workspace.Tycoons:FindFirstChild(Tycoon) then
		workspace.Tycoons[Tycoon].Owner.Value = "None"
		workspace.Tycoons[Tycoon].Tycoon:ClearAllChildren()
		workspace.Tycoons[Tycoon].Buttons:ClearAllChildren()
		workspace.Tycoons[Tycoon].Vehicles:ClearAllChildren()
		for i,v in (workspace.Tycoons[Tycoon]:GetChildren()) do
			if v:GetAttribute("Unload") then
				v:Destroy()
			end
		end
	else
		Ownership:CheckTycoons()
	end
end

function Ownership:CheckTycoons()
	for i, Tycoon in pairs(workspace.Tycoons:GetChildren()) do
		if not game.Players:FindFirstChild(Tycoon.Owner.Value) then
			Ownership:UnclaimTycoon(Tycoon.Name)
		end
	end
end

function Ownership:GetAvailableTycoon()
	local Available = {}
	
	for i = 1, 10, 1 do -- retry in case a player left and it didn't unload in time
		Ownership:CheckTycoons()
		
		for i, v in pairs(workspace.Tycoons:GetChildren()) do
			if v.Owner.Value == "None" then
				table.insert(Available, v.Name)
			end
		end
		
		if #Available > 0 then break else wait(0.2) end
	end
	
	return Available[Random.new():NextInteger(1, #Available)]
end

return Ownership