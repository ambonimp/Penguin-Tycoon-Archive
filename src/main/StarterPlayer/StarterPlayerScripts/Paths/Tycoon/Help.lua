local Help = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:WaitForChild(script.Name)


local IGNORED_BUTTONS = {
	["Glider#1"] = true,
	["Pets#1"] = true,
}

--- Help Variables ---
local PointerButton = UI.Right.Buttons.Pointer
local CurrentPointerButton = nil

local LastIsland

local function GetClosestButton(Buttons)
	local Closest
	local ClosestDist = math.huge

	local Root = Paths.Player.Character.HumanoidRootPart.Position
	for _, Button in ipairs(Buttons) do
		local Dist = (Root - Button.Hitbox.Position).Magnitude
		if Dist < ClosestDist then
			ClosestDist = Dist
			Closest = Button
		end
	end

	return Closest
end

local function GetCheapestButton(Buttons)
	local Cheapest
	local CheapestPrice = math.huge

	for _, Button in ipairs(Buttons) do
		local Price = Button:GetAttribute("Price")
		if Price < CheapestPrice then
			CheapestPrice = Price
			Cheapest = {Button}
		elseif Price == CheapestPrice then
			table.insert(Cheapest, Button)
		end
	end

	return Cheapest and GetClosestButton(Cheapest) or nil
end

local function GetButtonsOnIsland(Buttons)
	local Returning = {}

	if LastIsland then
		for _, Button in ipairs(Buttons) do
			if Button:GetAttribute("Island") == LastIsland then
				table.insert(Returning, Button)
			end
		end
	end

	return Returning
end


--- Help Functions ---
function Help:EnablePointerBeam()
	local Char = Paths.Player.Character
	
	if Char then
		local Root = Char:FindFirstChild("HumanoidRootPart") 
		
		if Root then
			local Buttons = Paths.Tycoon.Buttons:GetChildren()
			local PlayerMoney = Paths.Player:GetAttribute("Money")
			
			-- Find random purchaseable item AFFORDABLE
			local AffordableButtons = {}
			local UnaffordableButtons = {}
			for _, Button in pairs(Buttons) do
				if Button:FindFirstChild("Hitbox") then
					local Price = Button:GetAttribute("Price")
					local Type = Button:GetAttribute("CurrencyType")

					if Type ~= "Robux" and Type ~= "Gamepass" and not IGNORED_BUTTONS[Button.Name] then
						if PlayerMoney >= Price and Type ~= "Robux" then
							table.insert(AffordableButtons, Button)
						else
							table.insert(UnaffordableButtons, Button)
						end

					end

				end

			end
			
			local ChosenButton
			if #AffordableButtons > 0 then
				ChosenButton = GetCheapestButton(GetButtonsOnIsland(AffordableButtons))
				if not ChosenButton then
					ChosenButton = GetCheapestButton(AffordableButtons)
				end
			elseif #UnaffordableButtons > 0 then
				ChosenButton = GetCheapestButton(GetButtonsOnIsland(UnaffordableButtons))
				if not ChosenButton then
					ChosenButton = GetCheapestButton(UnaffordableButtons)
				end
			end
			
			-- Else find a random available item, if none can be afforded
			if not ChosenButton then Help:DisablePointerBeam() return end
			
			-- Make disable text visible
			PointerButton.Enable.Visible = false
			PointerButton.Disable.Visible = true
			
			-- Create beam
			local A1 = Root:FindFirstChild("Attachment") or Instance.new("Attachment", Root)
			
			local A2 = ChosenButton.Hitbox:FindFirstChild("Attachment") or Instance.new("Attachment", ChosenButton.Hitbox)
			
			local Beam = Root:FindFirstChild("Pointer") or Dependency.Pointer:Clone()
			Beam.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, ChosenButton.Part.Color),
				ColorSequenceKeypoint.new(1, ChosenButton.Part.Color)
			})
				
				
			Beam.Parent = Root
			Beam.Attachment0 = A1
			Beam.Attachment1 = A2
			
			CurrentPointerButton = ChosenButton
		end
	end
end

function Help:DisablePointerBeam()
	local Char = Paths.Player.Character

	if Char then
		local Root = Char:FindFirstChild("HumanoidRootPart") 

		if Root then
			local Beam = Root:FindFirstChild("Pointer")

			CurrentPointerButton = nil
			
			-- Make enable text visible
			PointerButton.Enable.Visible = true
			PointerButton.Disable.Visible = false
			
			if Beam then Beam:Destroy() end
		end
	end
end

function Help:ButtonRemoved(Button)
	if Button == CurrentPointerButton then
		wait(0.3) -- Wait for next buttons to get loaded in; otherwise it may point to a Robux button or error
		Help:EnablePointerBeam()
	end
end

PointerButton.MouseButton1Down:Connect(function()
	if CurrentPointerButton then
		Help:DisablePointerBeam()
	else
		Help:EnablePointerBeam()
	end
end)

task.defer(function()
	task.wait(3)
	local data = Paths.Remotes.GetStat:InvokeServer("Tycoon")
	if not data["Dock#1"] then
		Help:EnablePointerBeam()
	end

end)

Remotes.ButtonPurchased.OnClientEvent:Connect(function(_, _, Island)
	LastIsland = Island
end)

return Help