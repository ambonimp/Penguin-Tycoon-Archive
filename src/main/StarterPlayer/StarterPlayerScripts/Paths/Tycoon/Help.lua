local Help = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:WaitForChild(script.Name)

--- Help Variables ---
local PointerButton = UI.Right.Buttons.Pointer
local CurrentPointerItem = nil


--- Help Functions ---
function Help:EnablePointerBeam()
	local Char = Paths.Player.Character
	
	if Char then
		local Root = Char:FindFirstChild("HumanoidRootPart") 
		
		if Root then
			local AllItems = Paths.Tycoon.Buttons:GetChildren()
			local PlayerMoney = Paths.Player:GetAttribute("Money")
			
			local ChosenItem = nil
			
			-- Find random purchaseable item AFFORDABLE
			local AffordableItems = {}
			local NonRobuxItems = {}
			local AllValidItems = {}
			for i, v in pairs(AllItems) do
				if v:FindFirstChild("Hitbox") then
					local Price = v:GetAttribute("Price")
					local Type = v:GetAttribute("CurrencyType")
					print(Type,PlayerMoney,Price,Type == "Robux")
					if Type ~= "Robux" and Type ~= "Gamepass" then
						if PlayerMoney >= Price and Type ~= "Robux" then
							table.insert(AffordableItems, v)
						elseif Type ~= "Robux" then
							table.insert(NonRobuxItems, v)
						else
							table.insert(AllValidItems, v)
						end
					end
				else
					--warn("huhh", v) 
				end
			end
			
			if #AffordableItems > 0 then
				ChosenItem = AffordableItems[Random.new():NextInteger(1, #AffordableItems)]
			elseif #NonRobuxItems > 0 then
				ChosenItem = NonRobuxItems[Random.new():NextInteger(1, #NonRobuxItems)]
			elseif #AllValidItems > 0 then
				ChosenItem = AllValidItems[Random.new():NextInteger(1, #AllValidItems)]
			end
			
			
			-- Else find a random available item, if none can be afforded
			if not ChosenItem then Help:DisablePointerBeam() return end
			
			-- Make disable text visible
			PointerButton.Enable.Visible = false
			PointerButton.Disable.Visible = true
			
			-- Create beam
			local A1 = Root:FindFirstChild("Attachment") or Instance.new("Attachment", Root)
			
			local A2 = ChosenItem.Hitbox:FindFirstChild("Attachment") or Instance.new("Attachment", ChosenItem.Hitbox)
			
			local Beam = Root:FindFirstChild("Pointer") or Dependency.Pointer:Clone()
			Beam.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, ChosenItem.Part.Color), 
				ColorSequenceKeypoint.new(1, ChosenItem.Part.Color)
			})
				
				
			Beam.Parent = Root
			Beam.Attachment0 = A1
			Beam.Attachment1 = A2
			
			CurrentPointerItem = ChosenItem
		end
	end
end

function Help:DisablePointerBeam()
	local Char = Paths.Player.Character

	if Char then
		local Root = Char:FindFirstChild("HumanoidRootPart") 

		if Root then
			local Beam = Root:FindFirstChild("Pointer")

			CurrentPointerItem = nil
			
			-- Make enable text visible
			PointerButton.Enable.Visible = true
			PointerButton.Disable.Visible = false
			
			if Beam then Beam:Destroy() end
		end
	end
end

function Help:ButtonRemoved(Button)
	if Button == CurrentPointerItem then
		wait(0.3) -- Wait for next buttons to get loaded in; otherwise it may point to a Robux button or error
		Help:EnablePointerBeam()
	end
end

PointerButton.MouseButton1Down:Connect(function()
	if CurrentPointerItem then
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

return Help