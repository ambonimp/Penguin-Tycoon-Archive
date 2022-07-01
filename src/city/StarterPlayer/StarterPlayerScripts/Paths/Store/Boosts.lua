local Boosts = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Paths.Dependency:FindFirstChild("Boosts")

local Store = UI.Center.Store


--- Money Variables ---
local BoostsProducts = {1266980995,1266981097,1266981160,1266981422,1279118658,1279118733}
local NameToID = {
	["x3 Money"] = 1266980995,
	["Super Fishing Luck"] = 1266981097,
	["Ultra Fishing Luck"] = 1266981160,
	["Super Lucky Egg"] = 1279118658,
	["Ultra Lucky Egg"] = 1279118733,
}

local OwnedBoosts = Remotes.GetStat:InvokeServer("Boosts")
--- Functions ---
-- Load Products
for i, Product in pairs(BoostsProducts) do
	local s,m = pcall(function()
		local Info = Services.MPService:GetProductInfo(Product, Enum.InfoType.Product)

		local Template = Dependency.BoostTemplate:Clone()
		Template.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
		Template.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
		Template.BoostName.TheText.Text = Info["Name"]
		Template.Description.Text = Info["Description"]
		if Info["Name"] == "Fishing Luck Bundle" then
			Template.Use:Destroy()
			Template.Description.Text = string.gsub(Template.Description.Text, ",", "\n")
			Template.TimeLeft:Destroy()
			Template.Description.Size = UDim2.fromScale(.98,.325)
			Template.Description.Position = UDim2.fromScale(.5,.7)
		end
		Template.LayoutOrder = i
		Template.Name = Product

		Template.Purchase.MouseButton1Down:Connect(function()
			Services.MPService:PromptProductPurchase(Paths.Player, Product)
		end)

		if Template:FindFirstChild("Use") then
			Template.Use.TheText.Text = "Use ("..OwnedBoosts[Info["Name"]][1]..")"
			Template.Use.MouseButton1Down:Connect(function()
				Remotes.BoostHandler:FireServer("Start",Info["Name"])
			end)
		end

		Template.Parent = Store.Sections.Boosts.Holder.Boosts
	end)
	print(s,m)
end

function toMS(s)
	return string.format("%02i:%02i", s/60%60, s%60)
end

function Boosts:StartBoost(Boost)
	local Id = OwnedBoosts[Boost][3]

	local Template = Store.Sections.Boosts.Holder.Boosts:FindFirstChild(NameToID[Boost])
	local timeLeft = OwnedBoosts[Boost][2]
	Template.Use.TheText.Text = "Use ("..OwnedBoosts[Boost][1]..")"

	local cornerUI = Paths.UI.Top.Boosts:FindFirstChild(Boost)
	cornerUI.Visible = true
	Template:SetAttribute("Enabled",true)

	while timeLeft > 0 and Template:GetAttribute("Enabled") do
		timeLeft -= 1
		Template.TimeLeft.Text = toMS(timeLeft)
		cornerUI.TimeLeft.Text = Template.TimeLeft.Text
		task.wait(1)
	end

	if OwnedBoosts[Boost][3] == Id then
		Template.TimeLeft.Text = "15:00"
		Template:SetAttribute("Enabled",false)
		cornerUI.Visible = false
	end
end


Remotes.BoostHandler.OnClientEvent:Connect(function(Boost,Action,Data, Id)
	if Action == "Add" then
		OwnedBoosts = Data["Boosts"]
		local Template = Store.Sections.Boosts.Holder.Boosts:FindFirstChild(NameToID[Boost])
		if Template and Template:FindFirstChild("Use") then
			Template.Use.TheText.Text = "Use ("..OwnedBoosts[Boost][1]..")"
		else
			error("No Template For Boost "..Boost)
		end
	elseif Action == "Start" then
		OwnedBoosts = Data["Boosts"]
		Boosts:StartBoost(Boost)

	elseif Action == "End" then
		OwnedBoosts = Data["Boosts"]
		local Owned = OwnedBoosts[Boost][1]

		local Template = Store.Sections.Boosts.Holder.Boosts:FindFirstChild(NameToID[Boost])
		Template:SetAttribute("Enabled",false)

		local AutoActivate = UI.Center.Settings.Holder["Auto Activate Boosts"].Toggle.IsToggled.Value
		if AutoActivate and Owned > 0 then
			Remotes.BoostHandler:FireServer("Start", Boost)
		end
	end
end)


return Boosts