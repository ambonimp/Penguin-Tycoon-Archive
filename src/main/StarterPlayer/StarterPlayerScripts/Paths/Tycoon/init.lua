local Tycoon = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Connecting penguins to SetupPenguin() function ---
local TycoonSession = Modules.Maid.new()
local CollectPoint

local function NewObject(Object, Type)
	if Type then
		if Type == "Penguin" then
			Modules.Penguins:SetupPenguin(Object)
		end
	end
	if Modules.Pets then
		Modules.Pets.UpdateEggUI()
	end
end

-- Collecting
local function LoadCollecting(Hitbox)
	if not Hitbox or Hitbox.Name ~= "Hitbox" then return end
	warn("HELLO")
	local Db
	TycoonSession["Collect"] = Hitbox.Touched:Connect(function(Hit)
		local Character = Paths.Player.Character
		if Character and Hit:IsDescendantOf(Character) and not Db then
			Db = true
			print("TOUCH")

			local Income = CollectPoint:GetAttribute("Income")
			if not Income then
				TycoonSession["Collect"] = nil
			elseif Income > 0 then
				Remotes.CollectIncome:FireServer()
				-- FX
				local Sound = Hitbox:WaitForChild("Sound")
				Sound.TimePosition = 0.5
				Sound:Play()

				local Particles = Hitbox:WaitForChild("Particles")
				Particles.Currency:Emit(16)
				Particles.StarLeft:Emit(16)
				Particles.StarRight:Emit(16)

			end

			task.wait(1.5)
			Db = false

		end

	end)

end

local function LoadCollectPoint()
	TycoonSession:Destroy()
	CollectPoint = Paths.Tycoon.IncomeCollectPoint

	LoadCollecting(CollectPoint:FindFirstChild("Hitbox"))
	TycoonSession:GiveTask(CollectPoint.ChildAdded:Connect(LoadCollecting))

	TycoonSession:GiveTask(CollectPoint.ChildRemoved:Connect(function(Hitbox)
		if Hitbox.Name == "Hitbox" then
			TycoonSession["Collect"] = nil
		end
	end))

end


task.spawn(function()
	-- Collection point
	LoadCollectPoint()

	-- Laoing items
	Paths.Tycoon.Tycoon.ChildAdded:Connect(function(Object)
		local Type = Object:GetAttribute("Type")
		NewObject(Object, Type)

		Modules.AudioHandler:ItemPurchased()
	end)

	Paths.Tycoon.Buttons.ChildRemoved:Connect(function(Button)
		Modules.Help:ButtonRemoved(Button)
	end)

	for _, Object in pairs(Paths.Tycoon.Tycoon:GetChildren()) do
		local Type = Object:GetAttribute("Type")
		NewObject(Object, Type)
	end

	repeat task.wait() until Modules.Rebirths
	Modules.Rebirths.Rebirthed:Connect(LoadCollectPoint)

end)



-- Confetti
Remotes.ButtonPurchased.OnClientEvent:Connect(function(IslandIndex, Button)
	if Button == Modules.ProgressionDetails[IslandIndex].Object then
		Paths.Audio.Celebration:Play()
		Modules.UIAnimations.Confetti(2)
	end
end)

-- Minigames
for _, MinigameHandler in ipairs(script.Minigames:GetChildren()) do
	require(MinigameHandler)
end



return Tycoon