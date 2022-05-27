local Emotes = {}

--- Other Variables ---
local MPService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--- Accessory Variables ---
Emotes.StoreAmounts = {
	["Rare"] = 3;
	["Epic"] = 2;
	["Legendary"] = 1;
}

Emotes.RarityInfo = {
	["Free"] = {ID = 0000000000, Price = 1};
	["Event"] = {ID = 0000000000, Price = 1000};
	["Rare"] = {ID = 1231222253, Price = 99};
	["Epic"] = {ID = 1231222252, Price = 199};
	["Legendary"] = {ID = 1231222251, Price = 499};
}


--- Accessory Functions ---
function Emotes:ChooseStoreAccessories()
	local ChosenAccessories = {}

	for Rarity, Amount in pairs(Emotes.StoreAmounts) do
		local AccessoryList = {}

		for Accessory, Info in pairs(Emotes.All) do
			if Info.IsForSale and Info.Rarity == Rarity then
				table.insert(AccessoryList, Accessory)
			end
		end

		if #AccessoryList > Amount then
			for i = 1, Emotes.StoreAmounts[Rarity], 1 do
				local RandomNum = Random.new():NextInteger(1, #AccessoryList)
				local ChosenAccessory = AccessoryList[RandomNum]

				ChosenAccessories[ChosenAccessory] = true
				--table.insert(ChosenAccessories, ChosenAccessory)
				table.remove(AccessoryList, RandomNum)
			end
		end
	end

	return ChosenAccessories
end

local tweentime = {}
function resizeModel(model, a)
	local base = model.PrimaryPart
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Position = base.Position:Lerp(part.Position, a)
			part.Size *= a
			if part:FindFirstChildOfClass("SpecialMesh") then
				part:FindFirstChildOfClass("SpecialMesh").Scale *= a
			end
		end
	end
end

function tweenModelSize(model, duration, factor, easingStyle, easingDirection)
	local t = tick()
	tweentime[model] = t
	local s = factor - 1
	local i = 0
	local oldAlpha = 0
	while i < 1 and model do
		if tweentime[model] ~= t then
			break	
		end
		local dt = RunService.Heartbeat:Wait()
		i = math.min(i + dt/duration, 1)
		local alpha = TweenService:GetValue(i, easingStyle, easingDirection)
		resizeModel(model, (alpha*s + 1)/(oldAlpha*s + 1))
		oldAlpha = alpha
	end
end

--- Accessory Lists ---
Emotes.Unlockables = {

}


Emotes.All = {	
	--- Default Emotes ---
	["Sit"] = {ID = 8210283194, Rarity = "Free", IsForSale = false,Image = 8528062745};
	["Wave"] = {ID = 8210268481, Rarity = "Free", IsForSale = false,Image = 8528062380};
	["Sleep"] = {ID = 8210256955, Rarity = "Free", IsForSale = false,Image = 8528062526};
	["Point"] = {ID = 8210287558, Rarity = "Free", IsForSale = false,Image = 8528063110};
	["Salute"] = {ID = 8210276719, Rarity = "Free", IsForSale = false,Image = 8528062955};

	["Whack"] = {ID = 8210292011, Rarity = "Free", IsForSale = false,Image = 8527636138};
	["Dab"] = {ID = 8210285291, Rarity = "Free", IsForSale = false,Image = 8527637011};
	["Wavy"] = {ID = 8210280508, Rarity = "Free", IsForSale = false,Image = 8527636283};
	["Clap"] = {ID = 8210274153, Rarity = "Free", IsForSale = false,Image = 8527637084};
	["Hug"] = {ID = 8210270788, Rarity = "Free", IsForSale = false,Image = 8527636836};

	["Shy"] = {ID = 8210265638, Rarity = "Free", IsForSale = false,Image = 8527636506};
	["Floss"] = {ID = 8210262128, Rarity = "Free", IsForSale = false,Image = 8527636921};
	["Push Ups"] = {ID = 8210259556, Rarity = "Free", IsForSale = false,Image = 8527636706};

	["Bunny Hop"] = {ID = 9412022744, Rarity = "Event",EventName = "Egg Hunt", IsForSale = false,Image = 9375659185};
	["Eating Egg"] = {ID = 9412038945, Rarity = "Event",EventName = "Egg Hunt", IsForSale = false,Image = 9375658638,Prop = true,
		PropFunction = function(player,track)
			local cf = player.Character:GetPrimaryPartCFrame() 
			local prop = game.ReplicatedStorage.Assets["Chocolate Egg"]:Clone()
			prop:SetAttribute("Time",track.Length)
			resizeModel(prop,.01)
			player.Character.Humanoid.WalkSpeed = 0
			track:GetMarkerReachedSignal("START"):Connect(function()
				prop:SetPrimaryPartCFrame(cf*CFrame.new(0,1.5,-2.15))
				prop.Parent = workspace.Props

				tweenModelSize(prop, .4, 100, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
				for i = 1,3 do
					tweenModelSize(prop, .2, .75, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					task.wait(.1)
				end
			end)
			track:GetMarkerReachedSignal("END"):Connect(function()
				if prop then
					prop:Destroy()
				end
			end)
			player.Character.Humanoid.WalkSpeed = 32
			track:Play()
		end
	};
	["Finding Egg"] = {ID = 9412054426, Rarity = "Event",EventName = "Egg Hunt", IsForSale = false,Image = 9375658964,Prop = true,
		PropFunction = function(player,track)
			local cf = player.Character:GetPrimaryPartCFrame() 
			local prop = game.ReplicatedStorage.Assets["Gold Egg"]:Clone()
			prop:SetAttribute("Time",track.Length)
			resizeModel(prop,.01)
			prop.Parent = workspace.Props
			prop:SetPrimaryPartCFrame(cf*CFrame.new(0,-2,-2.5))
			player.Character.Humanoid.WalkSpeed = 0
			tweenModelSize(prop, .4, 85, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)


			track:GetMarkerReachedSignal("PICKUP"):Connect(function()
				if prop then
					for i,v in pairs (prop:GetChildren()) do
						v.Anchored = false
						if v ~= prop.PrimaryPart then
							local weld = Instance.new("WeldConstraint")
							weld.Part0 = prop.PrimaryPart
							weld.Part1 = v
							weld.Parent = v
						end
					end

					prop:SetPrimaryPartCFrame(prop:GetPrimaryPartCFrame()*CFrame.new(-.25,.25,0)*CFrame.Angles(math.rad(-65),0,math.rad(-10)))
	
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = player.Character["Arm L"]
					weld.Part1 = prop.PrimaryPart
					weld.Parent = prop.PrimaryPart
				end
			end)
			track:GetMarkerReachedSignal("DROP"):Connect(function()
				if prop then
					prop:Destroy()
				end
			end)
			player.Character.Humanoid.WalkSpeed = 32
			track:Play()
		end
	};
	["Stove Opening"] = {ID = 9185940435, Rarity = "Free", IsForSale = false,Image = 9193895325,Prop = true,
		PropFunction = function(player,track)
			local cf = player.Character:GetPrimaryPartCFrame() 

			track:Play()
			--[[local rayOrigin = cf.Position
			local rayDirection = player.Character:GetPrimaryPartCFrame().LookVector * 8

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {player.Character}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			
			if raycastResult then
				local hasOvenParent = raycastResult.Instance.Parent.Name == "Oven" or raycastResult.Instance.Parent.Parent.Name == "Oven" 
				if hasOvenParent then
					local oven
					if raycastResult.Instance.Parent.Name == "Oven" then
						oven = raycastResult.Instance.Parent
					elseif raycastResult.Instance.Parent.Parent.Name == "Oven" then
						oven = raycastResult.Instance.Parent.Parent
					end
					if oven then
						local door = oven:FindFirstChild("Door")
						if door then
							local opencf = door.OpenCF.Value
							local closedCF = door.ClosedCF.Value
							if door.Open.Value then
								door.Open.Value = false
								door:SetPrimaryPartCFrame(closedCF)
							else
								door.Open.Value = true
								door:SetPrimaryPartCFrame(opencf)
							end
						end
					end
				end
			end--]]
			track.Stopped:wait()
			game.ReplicatedStorage.Remotes.PropEmote:FireClient(player,"Stop")
		end,
	};
	["Dough Flipping"] = {ID = 9185954491, Rarity = "Free", IsForSale = false,Image = 9193827655,Prop = true,
		PropFunction = function(player,track)
			player.Character.Humanoid.WalkSpeed = 0
			local prop = game.ReplicatedStorage.Assets.Pizza_Dough_Disk:Clone()
			prop:SetAttribute("Time",track.Length)
			local runservice = game:GetService("RunService")
			local cf = player.Character.PrimaryPart.CFrame * CFrame.new(0,3,-1.5)
			local ended = false
			track:Play()
			spawn(function()
				resizeModel(prop,.01)
				wait(.35)
				if prop then
					prop:SetPrimaryPartCFrame(cf)
					prop.Parent = workspace.Props
					spawn(function()
						tweenModelSize(prop, .4, 80, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
					end)
					while not ended and prop and prop.PrimaryPart do
						if prop then
							prop:SetPrimaryPartCFrame(prop:GetPrimaryPartCFrame(cf)*CFrame.Angles(0,math.rad(15),0))
						end
						runservice.Stepped:wait()
					end
				end
			end)
			track.Stopped:wait()
			player.Character.Humanoid.WalkSpeed = 32
			ended = true
			if prop then
				spawn(function()
					tweenModelSize(prop, .4, .01, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					prop:Destroy()
				end)
			end
			game.ReplicatedStorage.Remotes.PropEmote:FireClient(player,"Stop")
		end,
	};
	["Cheering"] = {ID = 9185944642, Rarity = "Free", IsForSale = false,Image = 9193895715};
	["Crying"] = {ID = 9185949298, Rarity = "Free", IsForSale = false,Image = 9193895514};
	["Giving Pizza"] = {ID = 9193732375, Rarity = "Free", IsForSale = false,Image = 9193827514,Prop = true,
		PropFunction = function(player,track)
			player.Character.Humanoid.WalkSpeed = 0
			local prop = game.ReplicatedStorage.Assets.Pizza_Cooked:Clone()
			prop:SetAttribute("Time",track.Length)
			local runservice = game:GetService("RunService")
			local cf = player.Character.PrimaryPart.CFrame * CFrame.new(0,.75,-3)
			local ended = false
			track:Play()
			spawn(function()
				resizeModel(prop,.01)
				wait(.35)
				prop:SetPrimaryPartCFrame(cf)
				prop.Parent = workspace.Props
				spawn(function()
					tweenModelSize(prop, .4, 100, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
				end)
			end)
			track.Stopped:wait()
			player.Character.Humanoid.WalkSpeed = 32
			if prop then
				prop:Destroy()
			end
			game.ReplicatedStorage.Remotes.PropEmote:FireClient(player,"Stop")
		end};
	["Vegetable Cutting"] = {ID = 9193735267, Rarity = "Free", IsForSale = false,Image = 9193827407,Prop = true,
		PropFunction = function(player,track)
			player.Character.Humanoid.WalkSpeed = 0
			local prop

			if math.random(1,2) == 1 then
				prop = game.ReplicatedStorage.Assets.Cucumber:Clone()
			else
				prop = game.ReplicatedStorage.Assets.Tomato:Clone()
			end
			prop:SetAttribute("Time",track.Length)
			local runservice = game:GetService("RunService")
			local cf = player.Character.PrimaryPart.CFrame * CFrame.new(.5,.5,-2.65)
			local ended = false
			track:Play()
			spawn(function()
				resizeModel(prop,.01)
				wait(.25)
				prop:SetPrimaryPartCFrame(cf)
				prop.Parent = workspace.Props
				spawn(function()
					if prop.Name == "Tomato" then
						tweenModelSize(prop, .4, 150, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
					else
						tweenModelSize(prop, .4, 125, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
					end

				end)
			end)
			track.Stopped:wait()
			player.Character.Humanoid.WalkSpeed = 32
			if prop then
				prop:Destroy()
			end
			game.ReplicatedStorage.Remotes.PropEmote:FireClient(player,"Stop")
		end};




	--- Purchaseable Emotes ---
	-- Rares


	-- Epics


	-- Legendaries


}

return Emotes