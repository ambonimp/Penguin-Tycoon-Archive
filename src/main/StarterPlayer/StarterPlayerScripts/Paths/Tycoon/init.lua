local Tycoon = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Connecting penguins to SetupPenguin() function ---
local COLLECT_POINT_TAG = "IncomeCollectPoint"
local CollectPointConns = Modules.Maid.new()
local CollectPoints = {}

local function NewObject(Object, Type)
	if Type then
		if Type == "Penguin" then
			Modules.Penguins:SetupPenguin(Object)
		end
	end
	if Modules.Pets then
		Modules.Pets.UpdateEggUI()
	end
	if Modules.TycoonUIProgress then
		Modules.TycoonUIProgress.Update(Object.Name)
	end
end

task.spawn(function()
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

end)

local function UpdateStoreIncome(Point)
	Point:WaitForChild("BillboardGui").Amount.Text = "$" .. Modules.Format:FormatAbbreviated(Paths.Player:GetAttribute("Income")).."/3s"
	Point:WaitForChild("BillboardGui").Value.Text = "$" .. Modules.Format:FormatAbbreviated(Paths.Player:GetAttribute("StoredIncome"))
end

local function AutoIncomeCollect(Point)
	Point:WaitForChild("BillboardGui").Auto.Visible = true
end

local function LoadCollectPoint(Point)
	if not Point:IsDescendantOf(Paths.Tycoon) then return end

	local AutoCollect = Paths.Player:GetAttribute("AutoCollectIncome")

	if AutoCollect then
		AutoIncomeCollect(Point)
	else
		CollectPoints[Point] = true
		UpdateStoreIncome(Point)
		task.spawn(function()
			while Paths.Player do
				local Character = Paths.Player.Character
				if Character and Character.PrimaryPart and (Character.PrimaryPart.Position-Point.Position).magnitude<4.25 then
					warn("WHOAAAA")

					local Income = Paths.Player:GetAttribute("Income")
					if not Income then
						CollectPointConns["Collect"] = nil
					elseif Income > 0 then
						Remotes.CollectIncome:FireServer()
						-- FX
						local Sound = Point:WaitForChild("Sound")
						Sound.TimePosition = 0.5
						Sound:Play()

						local Particles = Point:WaitForChild("Particles")
						Particles.Currency:Emit(16)
						Particles.StarLeft:Emit(16)
						Particles.StarRight:Emit(16)

						task.wait(3)
					end
				end
				task.wait(.2)
			end
		end)
		
		--[[CollectPointConns[Point] = Point.Touched:Connect(function(Hit)
			

		end)]]

	end


end

-- Collecting
for _, Point in ipairs(Services.CollectionService:GetTagged(COLLECT_POINT_TAG)) do
	LoadCollectPoint(Point)
end

Services.CollectionService:GetInstanceAddedSignal(COLLECT_POINT_TAG):Connect(LoadCollectPoint)
Services.CollectionService:GetInstanceRemovedSignal(COLLECT_POINT_TAG):Connect(function(Point)
	if Point:IsDescendantOf(Paths.Tycoon) then
		CollectPoints[Point] = nil
		CollectPointConns[Point] = nil
	end
end)

CollectPointConns:GiveTask(Paths.Player:GetAttributeChangedSignal("StoredIncome"):Connect(function()
	for Point in pairs(CollectPoints) do
		UpdateStoreIncome(Point)
	end
end))

CollectPointConns:GiveTask(Paths.Player:GetAttributeChangedSignal("AutoCollectIncome"):Connect(function()
	for Point in pairs(CollectPoints) do
		AutoIncomeCollect(Point)
	end

	-- Let them reset to 0
	repeat task.wait() until Paths.Player:GetAttribute("StoredIncome") == 0
	CollectPointConns:Destroy()
	CollectPoints = {}

end))

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