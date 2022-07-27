local Milestones = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Handle Frame Buttons ---
local Frame = UI.Center.Achievements
local HUDBtn = UI.Bottom.Buttons.Achievements

local PreviousOpen = {
	[Frame] = Frame.Sections.Quests,
}

local Debounce = false




-- Toggles tiny red notification thing on hud button
local Badges = {Quests = 0, Achievements = 0}

local function BadgeSum()
	local Total = 0

	for _, v in pairs(Badges) do
		Total += v
	end

	return Total
end

function Milestones.Badge(Toggle, Section)
	if Toggle then
		Badges[Section] += 1
	else
		Badges[Section] -= 1
	end

	local SectionRemaining = Badges[Section]
	local SectionBadge = Frame.Buttons[Section].Badge
	if SectionRemaining == 0 then
		SectionBadge.Visible = false
	else
		SectionBadge.Visible = true
		SectionBadge.TextLabel.Text = SectionRemaining
	end


	local TotalRemaining = BadgeSum()
	local TotalBadge = HUDBtn.Badge
	if TotalRemaining == 0 then
		TotalBadge.Visible = false
	else
		TotalBadge.Visible = true
		TotalBadge.TextLabel.Text = TotalRemaining
	end

end

-- Initialize Accessories being open
Frame.Sections.Quests.Visible = true
Frame.Sections.Quests.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Buttons.Quests.BackgroundTransparency = 0.2


function Milestones.ButtonClicked(Button,Frame)
	if Debounce then return end
	Debounce = true

	-- If Button clicked is the same as previous open, just turn it off
	if PreviousOpen[Frame] ~= Frame.Sections[Button.Name] then
		-- Out
		PreviousOpen[Frame]:TweenPosition(UDim2.new(0.5, 0, 1.7, 0), "Out", "Quart", 0.2, true)
		Frame.Buttons[PreviousOpen[Frame].Name].BackgroundTransparency = 0.8
		
		-- In
		Frame.Sections[Button.Name].Position = UDim2.new(0.5, 0, 1.7, 0)
		Frame.Sections[Button.Name]:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quart", 0.2, true)
		Frame.Sections[Button.Name].Visible = true
		Button.BackgroundTransparency = 0.2
		
		task.wait(0.15)
		PreviousOpen[Frame].Visible = false
		PreviousOpen[Frame] = Frame.Sections[Button.Name]
	end

	Debounce = false
end



for _, Button in pairs(Frame.Buttons:GetChildren()) do
	if Button:IsA("ImageButton") then
		Button.MouseButton1Down:Connect(function()
			Milestones.ButtonClicked(Button,Frame)
		end)
	end
end

UI.Left.GemDisplay.Button.MouseButton1Down:Connect(function()
	Milestones.ButtonClicked(Frame.Buttons.Gifts,Frame)
end)

return Milestones