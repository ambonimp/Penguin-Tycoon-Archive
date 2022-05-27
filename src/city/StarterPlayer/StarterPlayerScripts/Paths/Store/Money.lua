local Money = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Store = UI.Center.Store
local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Money Variables ---
local MoneyProducts = {1224873708, 1224873843, 1224873847, 1224873846, 1224873844, 1224873842}


--- Functions ---

-- Load Products
for i, Product in pairs(MoneyProducts) do
	pcall(function()
		local Info = Services.MPService:GetProductInfo(Product, Enum.InfoType.Product)
		
		local Template = Dependency.MoneyTemplate:Clone()
		Template.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
		Template.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
		Template.LayoutOrder = Info["PriceInRobux"]
		Template.Name = Product
		
		Template.Purchase.MouseButton1Down:Connect(function()
			Services.MPService:PromptProductPurchase(Paths.Player, Product)
		end)
		
		Template.Parent = Store.Sections.Money.Holder.Money
	end)
end


function Money:UpdateMoneyRewards() -- Connected in UI.Updating
	local Income = Paths.Player:GetAttribute("Income")
	
	for i, Template in pairs(Store.Sections.Money.Holder.Money:GetChildren()) do
		if Template:IsA("Frame") and tonumber(Template.Name) then
			local Reward = Modules.GameFunctions:GetMoneyProductReward(Template.Name, Income)
			Template.ProductName.TheText.Text = "+ $ "..Modules.Format:FormatComma(Reward)
		end
	end
end

Money:UpdateMoneyRewards()


return Money