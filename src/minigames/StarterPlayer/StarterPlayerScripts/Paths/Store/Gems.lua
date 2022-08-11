local Gems = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Paths.Dependency:FindFirstChild("Money")

local Store = UI.Center.Store


--- Money Variables ---
local MoneyProducts = {
	[100] = 1266975588,[275] = 1266975627,[725] = 1266975643,[1500] = 1266975658,[2400] = 1266975679,[4250] = 1266975715}

--- Functions ---

-- Load Products
for amount, Product in pairs(MoneyProducts) do
	local s,m = pcall(function()
		local Info = Services.MPService:GetProductInfo(Product, Enum.InfoType.Product)
		
		local Template = Dependency.MoneyTemplate:Clone()
		Template.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
		Template.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
		Template.LayoutOrder = Info["PriceInRobux"]
		Template.Name = Product
		Template.Background.BackgroundColor3 = Color3.fromRGB(0,170,255)
		Template.Background.UIStroke.Color = Color3.fromRGB(0,170,255)
		Template.ProductName.TheText.Text = "+ "..Modules.Format:FormatComma(amount)

		Template.Purchase.MouseButton1Down:Connect(function()
			Services.MPService:PromptProductPurchase(Paths.Player, Product)
		end)
		
		Template.Parent = Store.Sections.Gems.Holder.Gems
	end)
end


return Gems