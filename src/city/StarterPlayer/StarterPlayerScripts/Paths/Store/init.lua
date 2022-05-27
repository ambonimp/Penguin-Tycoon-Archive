local Store = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Handle Store Buttons ---
local Store = UI.Center.Store

local PreviousOpen = {
	[Store] = Store.Sections.Accessory,
	[UI.Center.Clothing] = UI.Center.Clothing.Sections.Accessory,
}
	
local Debounce = false

-- Initialize Accessories being open
Store.Sections.Accessory.Visible = true
Store.Sections.Accessory.Position = UDim2.new(0.5, 0, 0.5, 0)
Store.Buttons.Accessory.BackgroundTransparency = 0.2

local function ButtonClicked(button,Store)
	if Debounce then return end
	Debounce = true

	-- If button clicked is the same as previous open, just turn it off
	if PreviousOpen[Store] ~= Store.Sections[button.Name] then
		-- Out
		PreviousOpen[Store]:TweenPosition(UDim2.new(0.5, 0, 1.7, 0), "Out", "Quart", 0.2, true)
		Store.Buttons[PreviousOpen[Store].Name].BackgroundTransparency = 0.8
		
		-- In
		Store.Sections[button.Name].Position = UDim2.new(0.5, 0, 1.7, 0)
		Store.Sections[button.Name]:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quart", 0.2, true)
		Store.Sections[button.Name].Visible = true
		button.BackgroundTransparency = 0.2
		
		task.wait(0.15)
		PreviousOpen[Store].Visible = false
		PreviousOpen[Store] = Store.Sections[button.Name]
	end

	Debounce = false
end

for i, Button in pairs(Store.Buttons:GetChildren()) do
	if Button:IsA("ImageButton") then
		Button.MouseButton1Down:Connect(function()
			ButtonClicked(Button,Store)
		end)
	end
end

UI.Left.Customization.Customization.Sections.Accessory.Holder.BuyAccessories.MouseButton1Down:Connect(function()
	ButtonClicked(Store.Buttons.Accessories,Store)
end)

UI.Left.Customization.Customization.Sections.Outfits.Holder.BuyOutfits.MouseButton1Down:Connect(function()
	ButtonClicked(UI.Center.Clothing.Buttons.Outfits,UI.Center.Clothing)
end)

UI.Left.Customization.Customization.Sections.Eyes.Holder.BuyEyes.MouseButton1Down:Connect(function()
	ButtonClicked(Store.Buttons.Accessories,Store)
end)

UI.BLCorner.MoneyDisplay.BuyMore.MouseButton1Down:Connect(function()
	ButtonClicked(Store.Buttons.Money,Store)
end)

for i, Button in pairs(UI.Center.Clothing.Buttons:GetChildren()) do
	Button.MouseButton1Down:Connect(function()
		ButtonClicked(Button,UI.Center.Clothing)
	end)
end


return Store