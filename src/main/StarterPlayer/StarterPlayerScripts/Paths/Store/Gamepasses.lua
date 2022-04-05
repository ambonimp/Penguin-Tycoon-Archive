local Gamepasses = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local Store = UI.Center.Store


--- Gamepass Variables ---
local AllGamepasses = {
	25313170,	 -- x2 Income
	26268187, -- Faster Speed
	26268229, -- Double Jump
	26269102, -- VIP
	28927736, -- Gold Fishing Rod
}



--- Functions ---

-- Updating the gamepass state (whether its owned or not )
function Gamepasses:SetOwned(Template)
	Template.Background.BackgroundColor3 = Color3.fromRGB(59, 162, 230)
	Template.Background.UIStroke.Color = Color3.fromRGB(96, 240, 255)
	Template.Purchase.Visible = false
	Template.Owned.Visible = true
end

Services.MPService.PromptGamePassPurchaseFinished:Connect(function(player, gamepass, purchased)
	if purchased then
		local Template = Store.Sections.Gamepasses.Holder[gamepass]
		Gamepasses:SetOwned(Template)
	end
end)

Remotes.Store.OnClientEvent:Connect(function(PurchaseType, gamepass, purchased)
	if PurchaseType == "Gamepass" and purchased then
		local Template = Store.Sections.Gamepasses.Holder:FindFirstChild(gamepass)
		if Template then
			Gamepasses:SetOwned(Template)
		end

		Modules.Settings:GamepassPurchased(gamepass)
	end
end)

-- Load Gamepasses
coroutine.wrap(function()
	task.wait(2)
	
	local OwnedPasses = Remotes.GetStat:InvokeServer("Gamepasses")
	repeat OwnedPasses = Remotes.GetStat:InvokeServer("Gamepasses") if not OwnedPasses then wait(1) end until OwnedPasses

	for i, Gamepass in pairs(AllGamepasses) do
		local Info = Services.MPService:GetProductInfo(Gamepass, Enum.InfoType.GamePass)

		if Info["IsForSale"] then
			local Template = Dependency.GamepassTemplate:Clone()

			Template.Name = Gamepass
			Template.PassName.TheText.Text = Info["Name"]
			Template.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
			Template.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
			
			if OwnedPasses[tostring(Gamepass)] then
				Gamepasses:SetOwned(Template)
			end

			Template.Parent = Store.Sections.Gamepasses.Holder

			Template.Purchase.MouseButton1Down:Connect(function()
				if Template.Purchase.Visible == true then
					Services.MPService:PromptGamePassPurchase(Paths.Player, Gamepass)
				end
			end)
		end
	end
end)()


return Gamepasses