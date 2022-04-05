local Store = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Handle Store Buttons ---
local Store = UI.Center.Store

local PreviousOpen = Store.Sections.Accessories
local Debounce = false

-- Initialize Accessories being open
Store.Sections.Accessories.Visible = true
Store.Sections.Accessories.Position = UDim2.new(0.5, 0, 0.5, 0)
Store.Buttons.Accessories.BackgroundTransparency = 0.2

local function ButtonClicked(button)
	if Debounce then return end
	Debounce = true

	-- If button clicked is the same as previous open, just turn it off
	if PreviousOpen ~= Store.Sections[button.Name] then
		-- Out
		PreviousOpen:TweenPosition(UDim2.new(0.5, 0, 1.7, 0), "Out", "Quart", 0.2, true)
		Store.Buttons[PreviousOpen.Name].BackgroundTransparency = 0.8
		
		-- In
		Store.Sections[button.Name].Position = UDim2.new(0.5, 0, 1.7, 0)
		Store.Sections[button.Name]:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quart", 0.2, true)
		Store.Sections[button.Name].Visible = true
		button.BackgroundTransparency = 0.2
		
		task.wait(0.15)
		PreviousOpen.Visible = false
		PreviousOpen = Store.Sections[button.Name]
	end

	Debounce = false
end

for i, Button in pairs(Store.Buttons:GetChildren()) do
	Button.MouseButton1Down:Connect(function()
		ButtonClicked(Button)
	end)
end

UI.Left.Customization.Customization.Sections.Accessory.Holder.BuyAccessories.MouseButton1Down:Connect(function()
	ButtonClicked(Store.Buttons.Accessories)
end)

UI.Left.Customization.Customization.Sections.Eyes.Holder.BuyEyes.MouseButton1Down:Connect(function()
	ButtonClicked(Store.Buttons.Accessories)
end)


-- Refresh button
Store.Sections.Accessories.Refresh.MouseButton1Down:Connect(function()
	Services.MPService:PromptProductPurchase(Paths.Player, 1233004731)
end)


return Store