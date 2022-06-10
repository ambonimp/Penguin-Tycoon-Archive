local Achievements = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Handle Store Buttons ---
local Store = UI.Center.Achievements

local PreviousOpen = {
	[Store] = Store.Sections.Quests,
}
	
local Debounce = false

-- Initialize Accessories being open
Store.Sections.Quests.Visible = true
Store.Sections.Quests.Position = UDim2.new(0.5, 0, 0.5, 0)
Store.Buttons.Quests.BackgroundTransparency = 0.2

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

UI.Left.GemDisplay.Button.MouseButton1Down:Connect(function()
	ButtonClicked(Store.Buttons.Gifts,Store)
end)


return Achievements