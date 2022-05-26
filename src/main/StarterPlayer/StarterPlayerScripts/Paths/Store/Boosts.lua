local Gems = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Paths.Dependency:FindFirstChild("Boosts")

local Store = UI.Center.Store


--- Money Variables ---
local BoostsProducts = {1266980995,1266981097,1266981160,1266981422}
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
		if Template:FindFirstChild("Use") then
			Template.Use.TheText.Text = "Use("..OwnedBoosts[Info["Name"]][1]..")"
		end
		Template.LayoutOrder = i
		Template.Name = Product
		
		Template.Purchase.MouseButton1Down:Connect(function()
			Services.MPService:PromptProductPurchase(Paths.Player, Product)
		end)
		
		Template.Parent = Store.Sections.Boosts.Holder.Boosts
	end)
end


return Gems