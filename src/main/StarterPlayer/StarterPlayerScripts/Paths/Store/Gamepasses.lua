local Gamepasses = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local Popups = require(script.Parent.Popups)
local Store = UI.Center.Store
Modules.Popups = Popups
Gamepasses.Owned = {}

--- Gamepass Variables ---
local AllGamepasses = {
	{25313170,"Double your income!",Color3.new(0.498039, 0.811764, 0.086274)},	 -- x2 Income
	{26268187,"Run faster!"}, -- Faster Speed
	{26268229,"Jump twice!"}, -- Double Jump
	{26269102,"VIP Tag and Golden Hearts!"}, -- VIP
	{28927736,"Catch fish twice as fast!"}, -- Gold Fishing Rod
	{41205566,"Luxury Boat that drives faster!"}, -- Luxury Boat
	{41205759,"Fly twice as fast!"}, -- Super Glider
	{43183311,"Double money from chopped trees!"}, -- Gold Axe
	{45764173,"Fly fast in a cool jet!"}, -- Jet Plane
	{47438416,"Catch fish twice as fast and increase the chance of catching rainbow fish!"}, -- rainbow fishing rod,
	{47438471,"Double gems from everything!"}, -- x2 gems
	{47438595,"Ability to use the map in Penguin City!"}, -- map teleport
	{49090546, "Capture 3 fish per cast!"},
	{52724179, "Double money from ores mined!"}, -- Gold Pickaxe
	{55102169, "Add 100 pet storage space!"},
	{55102286, "Add 300 pet storage space!"},
	{56637668, "Auto Hatch eggs!"},
	{56844198, "Increases your egg luck by 20%"}
}

Popups.load(AllGamepasses)

--- Functions ---

-- Updating the gamepass state (whether its owned or not )
function Gamepasses:SetOwned(Template)
	Template.Background.BackgroundColor3 = Color3.fromRGB(59, 162, 230)
	Template.Background.UIStroke.Color = Color3.fromRGB(96, 240, 255)
	Template.Purchase.Visible = false
	Template.Owned.Visible = true
	Gamepasses.Owned[tonumber(Template.Name)] = true
	Template.LayoutOrder = 999999
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
task.spawn(function()
	task.wait(2)
	
	local OwnedPasses = nil
	repeat OwnedPasses = Remotes.GetStat:InvokeServer("Gamepasses") if not OwnedPasses then wait(1) end until OwnedPasses

	for i, Gamepass in pairs(AllGamepasses) do
		local Info
		for _ = 1, 5 do
			local Success, Results = pcall(function()
				return Services.MPService:GetProductInfo(Gamepass[1], Enum.InfoType.GamePass)
			end)
			if Success then
				Info = Results
				break
			end
		end

		if Info["IsForSale"] then
			local Template = Dependency.GamepassTemplate:Clone()

			Template.Name = Gamepass[1]
			Template.PassName.TheText.Text = Info["Name"]
			Template.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
			Template.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
			Template.Description.Text = Gamepass[2]
			if OwnedPasses[tostring(Gamepass[1])] or OwnedPasses[Gamepass[1]]  then
				Gamepasses:SetOwned(Template)
			end

			Template.Parent = Store.Sections.Gamepasses.Holder

			Template.Purchase.MouseButton1Down:Connect(function()
				if Template.Purchase.Visible == true then
					Services.MPService:PromptGamePassPurchase(Paths.Player, Gamepass[1])
				end
			end)

		end

	end

end)

return Gamepasses