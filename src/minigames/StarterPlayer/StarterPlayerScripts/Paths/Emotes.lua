local Emotes = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local AllEmotes = require(Services.RStorage.Modules.AllEmotes)

--- Emotes Variables ---
local EmoteDisplay = UI.Bottom.EmotesDisplay
local EmoteMenu = UI.Bottom.EmotesMenu
local EmoteButton = UI.Bottom.Buttons.Emotes

local EmoteDB = false
local PreviousEmote = false

local DisplayUIVisible = false
local MenuUIVisible = false
local UIDebounce = false
local playingPropAnim = false


local AnimationTracks = {}

local blacklistTools = {"Glider"}

function findByID(ID)
	for i,v in pairs (AllEmotes.All) do
		if v.ID == ID then
			return v,i
		end
	end
	return nil
end

--- Functions ---

--- Animation Functions ---
local function LoadEmote(ID)
	print("Loademote",ID)
	if Paths.Player.Character and Paths.Player.Character:FindFirstChild("Humanoid") and not AnimationTracks[ID] then
		local Animator = Paths.Player.Character.Humanoid:FindFirstChild("Animator") or Paths.Player.Character.Humanoid
		
		local Animation = Dependency:FindFirstChild(tostring(ID)) or Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://"..ID
		Animation.Name = ID
		Animation.Parent = Dependency
		
		AnimationTracks[ID] = Animator:LoadAnimation(Animation)
		AnimationTracks[ID].Priority = Enum.AnimationPriority.Action
		--AnimationTracks[ID].Looped = true
		
		return AnimationTracks[ID]
		
	elseif Paths.Player.Character and Paths.Player.Character:FindFirstChild("Humanoid") and AnimationTracks[ID] then
		return AnimationTracks[ID]
		
	else
		return false
	end
end

local function CanPlayEmote()
	if EmoteDB then
		return false
	end
	
	return true
end

Paths.Services.RStorage.Remotes.PropEmote.OnClientEvent:Connect(function(ty)
	if ty == "Stop" then
		playingPropAnim = nil
	end
end)

function Emotes:PlayEmote(ID)
	if not CanPlayEmote() then return end
	local emote,name = findByID(ID)
	if emote and name then
		if playingPropAnim == name then
			Paths.Services.RStorage.Remotes.PropEmote:FireServer(playingPropAnim,"End")
			playingPropAnim = nil
			return 
		end
		if emote.Prop then
			if playingPropAnim then
				Paths.Services.RStorage.Remotes.PropEmote:FireServer(playingPropAnim,"End")
			end
			if PreviousEmote then
				PreviousEmote:Stop()
			end
			playingPropAnim = name
			Paths.Services.RStorage.Remotes.PropEmote:FireServer(name,"Start")
			return
		end
	end
	if playingPropAnim then
		Paths.Services.RStorage.Remotes.PropEmote:FireServer(playingPropAnim,"End")
		playingPropAnim = nil
	end
	EmoteDB = true
	local Track = LoadEmote(ID)
	if Track then
		if PreviousEmote then
			PreviousEmote:Stop(0)
		end

		if Paths.Player.Character:FindFirstChild("Main") then
			Paths.Player.Character.Main.CanCollide = false
		end
		
		Track:Play()
		--Track:AdjustSpeed(0.2)
		PreviousEmote = Track
	end

	task.wait()
	EmoteDB = false
end

function Emotes:NewCharacter(Character)
	AnimationTracks = {}
	
	local Humanoid = Character:WaitForChild("Humanoid", 3)
	if not Humanoid then return end

	Humanoid.Changed:Connect(function(Property)
		if Property == "MoveDirection" then
			if PreviousEmote then
				PreviousEmote:Stop(0.1)
				PreviousEmote = nil
				
				if Character:FindFirstChild("Main") then
					Character.Main.CanCollide = true
				end
			end
		end
	end)
end



--- UI Functions ---
Emotes.FullSize = EmoteDisplay.Size

function Emotes:EnterUI(UI)
	DisplayUIVisible = true
	MenuUIVisible = (UI == "Menu")
	
	if UI == "Display" then
		EmoteDisplay.Size = UDim2.new(0.165, 0, 0.02, 0)
		EmoteDisplay.Visible = true
		EmoteDisplay:TweenSize(Emotes.FullSize, "Out", "Back", 0.16, true)
	elseif UI == "Menu" then
		EmoteMenu.Size = UDim2.new(0.75, 0, 0.02, 0)
		EmoteMenu.Visible = true
		EmoteMenu:TweenSize(UDim2.new(0.75, 0, 0.8, 0), "Out", "Back", 0.16, true)
	end
end

function Emotes:ExitUI(UI)
	MenuUIVisible = false
	
	if UI == "Display" then
		DisplayUIVisible = false
		EmoteDisplay:TweenSize(UDim2.new(0.165, 0, 0.02, 0), "In", "Back", 0.16, true)
	end
	EmoteMenu:TweenSize(UDim2.new(0.75, 0, 0.02, 0), "In", "Back", 0.16, true)
	EmoteDisplay.Expand.ExpandIcon.Visible = not MenuUIVisible
	EmoteDisplay.Expand.HideIcon.Visible = MenuUIVisible
	
	coroutine.wrap(function()
		task.wait(0.15)
		EmoteDisplay.Visible = not (UI == "Display")
		EmoteMenu.Visible = false
	end)()
end


-- Opening EmotesDisplay UI
EmoteButton.MouseButton1Down:Connect(function()
	if UIDebounce then return end
	UIDebounce = true
	
	if DisplayUIVisible then
		Emotes:ExitUI("Display")
	else
		Emotes:EnterUI("Display")
	end
	
	task.wait(0.16)
	UIDebounce = false
end)

-- Opening EmotesMenu UI
EmoteDisplay.Expand.MouseButton1Down:Connect(function()
	if UIDebounce then return end
	UIDebounce = true

	if MenuUIVisible then
		Emotes:ExitUI("Menu")
	else
		Emotes:EnterUI("Menu")
	end

	EmoteDisplay.Expand.ExpandIcon.Visible = not MenuUIVisible
	EmoteDisplay.Expand.HideIcon.Visible = MenuUIVisible

	task.wait(0.16)
	UIDebounce = false
end)



--- Equipping Emotes ---
local EquippedEmotes = {}
local SelectedEmote = nil

local function EnterEquipMode(Emote)
	SelectedEmote = Emote
	EmoteDisplay.Emotes.Equip.Visible = true
end

local function ExitEquipMode()
	SelectedEmote = nil
	EmoteDisplay.Emotes.Equip.Visible = false
end

for i, SlotTemplate in pairs(EmoteDisplay.Emotes.Equip:GetChildren()) do
	if SlotTemplate:IsA("ImageButton") then
		SlotTemplate.MouseButton1Down:Connect(function()
			if SelectedEmote then
				local Slot = string.split(SlotTemplate.Name, "Emote")[2]
				Emotes:EquipEmote(SelectedEmote, Slot)
			end
			ExitEquipMode()
		end)
	end
end



--- Loading Emotes ---
function Emotes:NewEmote(Emote)
	local Template = Dependency.EmoteTemplate:Clone()
	Template.Name = Emote
	Template.EmoteName.Text = Emote
	Template.EmoteIcon.Image = "rbxassetid://"..Modules.AllEmotes.All[Emote].Image
	Template:SetAttribute("AnimationID", Modules.AllEmotes.All[Emote].ID)
	
	Template.MouseButton1Down:Connect(function()
		-- Prevent players from equipping already equipped emotes
		for Slot, EquippedEmote in pairs(EquippedEmotes) do
			if EquippedEmote == Emote then
				return
			end
		end
		EnterEquipMode(Emote)
	end)
	
	Template.Parent = EmoteMenu.Holder
end

function Emotes:EquipEmote(Emote, Slot)
	print(Emote,Slot)
	local SlotTemplate = EmoteDisplay.Emotes.Holder["Emote"..Slot]
	
	-- Unequip previous emote 
	if EquippedEmotes[tostring(Slot)] then
		EmoteMenu.Holder[EquippedEmotes[tostring(Slot)]].EquippedTo.Visible = false
		--EmoteMenu.Holder[EquippedEmotes[tostring(Slot)]].LayoutOrder = 6
	end
	
	-- Equip new emote
	SlotTemplate.EmoteIcon.Image = "rbxassetid://"..Modules.AllEmotes.All[Emote].Image
	SlotTemplate:SetAttribute("AnimationID", Modules.AllEmotes.All[Emote].ID)
	EquippedEmotes[tostring(Slot)] = Emote
	
	local Template = EmoteMenu.Holder:FindFirstChild(Emote)
	--Template.LayoutOrder = Slot
	Template.EquippedTo.Text = Slot
	Template.EquippedTo.Visible = true
	
	Remotes.Customization:InvokeServer("Equip Emote", Emote, Slot)
end


EmoteMenu.Holder.UIGridLayout.SortOrder = Enum.SortOrder.Name
for i, Emote in pairs(EmoteDisplay.Emotes.Holder:GetChildren()) do
	if Emote:IsA("ImageButton") then
		Emote.MouseButton1Down:Connect(function()
			Emotes:PlayEmote(Emote:GetAttribute("AnimationID"))
		end)
	end
end

-- Loading current player items
coroutine.wrap(function()
	-- Loading emotes
	local PlayerEmotes = Remotes.GetStat:InvokeServer("Emotes")
	EquippedEmotes = Remotes.GetStat:InvokeServer("Equipped Emotes")
	repeat 
		PlayerEmotes = Remotes.GetStat:InvokeServer("Emotes")
		EquippedEmotes = Remotes.GetStat:InvokeServer("Equipped Emotes")
		if PlayerEmotes and EquippedEmotes then break else wait(1) end 
	until PlayerEmotes and EquippedEmotes

	for Emote, IsOwned in pairs(PlayerEmotes) do
		if IsOwned then
			Emotes:NewEmote(Emote)
		end
	end
	
	Services.RStorage.Remotes.NewEmote.OnClientEvent:Connect(function(emote)
		Emotes:NewEmote(emote)
	end)

	for Slot, EquippedEmote in pairs(EquippedEmotes) do
		Emotes:EquipEmote(EquippedEmote, Slot)
	end
end)()


return Emotes