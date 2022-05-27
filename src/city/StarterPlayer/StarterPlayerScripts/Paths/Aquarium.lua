local TweenService = game:GetService("TweenService")
local Acquarium = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local TweenService = Services.TweenService
local FishingConfig = Modules.FishingConfig
local AcquariumFolder = workspace:WaitForChild("Aquarium")
local FishFolder = AcquariumFolder:WaitForChild("Fish")

repeat task.wait(.1) until #FishFolder:GetChildren() >= 22

local OwnedFish = Remotes.GetStat:InvokeServer("Fish Found")

function loadFish(ID,Part)
	Part.Transparency = 1
	ID = tonumber(ID)
	local fishPart = Services.RStorage.Assets.Fishes:FindFirstChild(FishingConfig.ItemList[ID].Name)
	if fishPart then
		fishPart = fishPart:Clone()
		fishPart.CFrame = Part.CFrame * CFrame.Angles(0,math.rad(-90),0)
		fishPart.Size = fishPart.Size * math.random(950,1300)/1000
		fishPart.Anchored = true
		local attachments = nil
		if math.random(1,100) <= 10 then
			local glow = Services.RStorage.Assets.Glow
			for i,v in pairs (glow:GetChildren()) do
				v:Clone().Parent = fishPart
			end
		end
		if Part:FindFirstChildOfClass("Attachment") then
			attachments = {}
			for i = 1,#Part:GetChildren() do
				table.insert(attachments,Part:FindFirstChild(i))
			end
		end
		fishPart.Parent = Part
		if attachments then
			fishPart.CFrame = attachments[1].WorldCFrame
			task.spawn(function()
				while true do
					if Paths.Player:DistanceFromCharacter(fishPart.Position) < 500 then
						for i = 1,#attachments do
							local prev1 = attachments[i-1]
							if prev1 == nil then
								prev1 = attachments[#attachments]
							end
							local worldcf = attachments[i].WorldCFrame
							local time1 = ((prev1.WorldCFrame.Position-attachments[i].WorldCFrame.Position).magnitude/3) * math.random(900,1100)/1000
							local Info = TweenInfo.new(time1)
							local tween = TweenService:Create(fishPart,Info,{CFrame = worldcf * CFrame.Angles(0,math.rad(-90),0)})
							tween:Play()
							task.wait(Info.Time*.85)
						end
					end
					task.wait()
				end
			end)
		end
	else
		warn("Fish",ID,FishingConfig.ItemList[ID].Name," doesn't exist.")
	end
end

task.spawn(function()
	local fishAmount = #FishFolder:GetChildren()
	local toLoadFish = {}
	local totalFish = 0
	
	for i,v in pairs (OwnedFish) do
		table.insert(toLoadFish,i)
		totalFish += 1
	end
	
	for i = 1,fishAmount do
		local r = math.random(1,totalFish)
		local fishID = toLoadFish[r]
		fishID = tonumber(fishID)
		if FishingConfig.ItemList[fishID] == nil or Services.RStorage.Assets.Fishes:FindFirstChild(FishingConfig.ItemList[fishID].Name) == nil then
			while FishingConfig.ItemList[fishID] == nil or Services.RStorage.Assets.Fishes:FindFirstChild(FishingConfig.ItemList[fishID].Name) == nil do
				r += 1
				if r > #toLoadFish then
					r = 1
				end
				fishID = tonumber(toLoadFish[r])
				task.wait()
			end
		end
		loadFish(fishID,FishFolder:GetChildren()[i])
		totalFish -= 1
	end
end)

return Acquarium