local Hearts = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Hearts Variables ---
local PlayerList = Paths.UI.Center.Hearts.PlayerList
local HeartsGiven = Remotes.GetStat:InvokeServer("Regular Hearts Given")
local VIPHeartsGiven = Remotes.GetStat:InvokeServer("VIP Hearts Given")

local HeartsDB = false


--- Heart Functions ---
function Hearts:UpdateHeartsGiven()
	HeartsGiven = Remotes.GetStat:InvokeServer("Regular Hearts Given")
	VIPHeartsGiven = Remotes.GetStat:InvokeServer("VIP Hearts Given")
end


function Hearts:NewPlayer(Player)
	if PlayerList:FindFirstChild(Player.Name) then return end
	
	local Template = Dependency.PlayerTemplate:Clone()
	Template.Name = Player.Name
	Template.PlayerName.Text = Player.DisplayName
	Template.Hearts.Text = Player:GetAttribute("Hearts") or 0
	
	Template.Give.Done.Visible = HeartsGiven[tostring(Player.UserId)]
	Template.VIPGive.Done.Visible = VIPHeartsGiven[tostring(Player.UserId)]
	
	-- Updating hearts
	Player:GetAttributeChangedSignal("Hearts"):Connect(function()
		Template.Hearts.Text = Player:GetAttribute("Hearts") or 0
	end)
	
	-- Regular Give Button
	Template.Give.MouseButton1Down:Connect(function()
		local PlayerToGive = game.Players:FindFirstChild(Template.Name)

		if PlayerToGive and Template.Give.Done.Visible == false and not HeartsDB then
			HeartsDB = true
			
			local Success, GaveHeart, NewAmount = pcall(function() return Remotes.Hearts:InvokeServer(PlayerToGive, "Regular") end)
			if Success and GaveHeart then
				Template.Give.Done.Visible = Success
				Template.Hearts.Text = NewAmount or Template.Hearts.Text
			else
				Template.Give.Error.Visible = true
				wait(0.8)
				Template.Give.Error.Visible = false
			end

			HeartsDB = false
		end
	end)
	
	-- VIP Give Button
	local IsVIP = Paths.UI.Center.Store.Sections.Gamepasses.Holder:WaitForChild("26269102").Owned.Visible
	Template.VIPGive.Locked.Visible = not IsVIP
	
	Template.VIPGive.MouseButton1Down:Connect(function()
		IsVIP = Paths.UI.Center.Store.Sections.Gamepasses.Holder:WaitForChild("26269102").Owned.Visible
		
		if IsVIP then
			local PlayerToGive = game.Players:FindFirstChild(Template.Name)
			
			if PlayerToGive and Template.VIPGive.Done.Visible == false and not HeartsDB then
				HeartsDB = true

				local Success, GaveHeart, NewAmount = pcall(function() return Remotes.Hearts:InvokeServer(PlayerToGive, "VIP") end)
				if Success and GaveHeart then
					Template.VIPGive.Done.Visible = Success
					Template.Hearts.Text = NewAmount or Template.Hearts.Text
				else
					Template.VIPGive.Error.Visible = true
					wait(0.8)
					Template.VIPGive.Error.Visible = false
				end
				
				HeartsDB = false
			end
		else
			Services.MPService:PromptGamePassPurchase(Paths.Player, 26269102)
		end
	end)
	
	Template.Parent = PlayerList
end


function Hearts:AcquiredVIP()
	for i, Template in pairs(PlayerList:GetChildren()) do
		if Template:IsA("Frame") then
			Template.VIPGive.Locked.Visible = false
		end
	end
end


function Hearts:PlayerRemoved(Player)
	if PlayerList:FindFirstChild(Player.Name) then
		PlayerList[Player.Name]:Destroy()
	end
end


--- Receiving Hearts ---
local GiftReceivedUI = Paths.UI.Center.GiftReceived

local HeartAmounts = {["Regular"] = 1, ["VIP"] = 3}

function Hearts:HeartReceived(PlayerGiving, GiftType)
	if Paths.UI.Center.Settings.Holder["Heart Notifications"].Toggle.IsToggled.Value == false then return end
	
	local notification = Dependency.HeartReceived:Clone()
	notification.LayoutOrder = #Paths.UI.Main.Notifications:GetChildren() + 1
	notification.Title.Text = "Received "..HeartAmounts[GiftType].." Heart(s)!"
	notification.Player.Text = PlayerGiving
	notification.Parent = Paths.UI.Main.Notifications
	
	wait(3)
	
	for i = 1, 10 do
		notification.BackgroundTransparency += 0.1
		notification.Title.TextTransparency += 0.2
		notification.Title.TextStrokeTransparency += 0.1
		notification.Player.TextTransparency += 0.2
		notification.Player.TextStrokeTransparency += 0.1
		notification.From.TextTransparency += 0.2
		notification.From.TextStrokeTransparency += 0.1
		notification.UIStroke.Transparency += 0.2
		
		wait()
	end
	
	notification:Destroy()
end

GiftReceivedUI.Claim.MouseButton1Down:Connect(function()
	GiftReceivedUI:TweenPosition(UDim2.new(0.5, 0, 2, 0), "In", "Back", 0.2, true)
end)

Remotes.Hearts.OnClientInvoke = function(Action, Info, Info2)
	if Action == "Heart Received" then
		Hearts:HeartReceived(Info, Info2)
	end
end



--- Load Players ---
game.Players.PlayerAdded:Connect(function(Player)
	Hearts:UpdateHeartsGiven()
	Hearts:NewPlayer(Player)
end)
coroutine.wrap(function()
	for i, Player in pairs(game.Players:GetPlayers()) do
		Hearts:NewPlayer(Player)
	end
end)()

-- Remove Players
game.Players.PlayerRemoving:Connect(function(Player)
	Hearts:PlayerRemoved(Player)
end)


return Hearts