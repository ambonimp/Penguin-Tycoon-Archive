local Workspace = game:GetService("Workspace")
local Teleporting = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local EventsConfig =  require(Services.RStorage.Modules.EventsConfig)
local PlaceIds =  require(Services.RStorage.Modules.PlaceIds)


--- Variables ---
local TeleportButton = UI.Left.Buttons.Teleport
local Confirmation = UI.Center.TeleportConfirmation

local TeleportDB = false


local Locations = {
	["Penguin Tycoon"] = {
		PlaceId = PlaceIds["Penguin Tycoon"],
		Alias = "Tycoon",
		Description = "Build your islands, customize your Penguins and earn money!",
		Thumbnail = "rbxassetid://8455934474"
	},
	["Penguin City"] = {
		PlaceId = PlaceIds["Penguin City"],
		Alias = "City",
		Description = "Play Minigames, Visit your Friends, and Roleplay",
		Thumbnail = "rbxassetid://8455934474"
	},
	["Falling Tiles"] = {
		PlaceId = PlaceIds["Falling Tiles"],
		Description = "Be the last man standing",
		Thumbnail = "rbxassetid://" .. EventsConfig["Falling Tiles"].ImageID,
	},
	["Skate Race"] = {
		PlaceId = PlaceIds["Skate Race"],
		Description = "Race on skates",
		Thumbnail = "rbxassetid://" .. EventsConfig["Skate Race"].ImageID,
	},
	["Soccer"] = {
		PlaceId = PlaceIds["Soccer"],
		Description = "Score as many goals",
		Thumbnail = "rbxassetid://" .. EventsConfig["Soccer"].ImageID,
	},
	["Candy Rush"] = {
		PlaceId = PlaceIds["Candy Rush"],
		Description = "Something",
		Thumbnail = "rbxassetid://" .. EventsConfig["Candy Rush"].ImageID,
	}
}

--- Functions ---
function Teleporting:TeleportTo(PlaceId)
	if TeleportDB then return end
	TeleportDB = true

	local Success, Error = Remotes.Teleport:InvokeServer(PlaceId)

	if not Success then
		Confirmation.InfoHolder.Confirm.Error.Visible = true
		wait(0.8)
		Confirmation.InfoHolder.Confirm.Error.Visible = false
	end
	TeleportDB = false
end


function Teleporting:OpenConfirmation(Location)
	local LocationInfo = Locations[Location]

	if LocationInfo then
		Confirmation.InfoHolder.Thumbnail.Image = LocationInfo.Thumbnail
		Confirmation.InfoHolder.Description.Text = LocationInfo.Description
		Confirmation.InfoHolder.TeleportingTo.Text = "Teleporting To: " .. Location

		Confirmation.PlaceId.Value = LocationInfo.PlaceId
	else
		warn(Location, debug.traceback())
	end

end


-- Confirmation UI buttons
Confirmation.InfoHolder.Confirm.MouseButton1Down:Connect(function()
	Teleporting:TeleportTo(tonumber(Confirmation.PlaceId.Value))
end)

--Confirmation.Cancel.MouseButton1Down:Connect(function()
--	Confirmation.Visible = false
--end)


-- Different teleport locations/buttonns
TeleportButton.MouseButton1Down:Connect(function()
	Teleporting:OpenConfirmation("Penguin City")
end)


--- Switching between tabs ---
Confirmation.InfoHolder.Friends.MouseButton1Down:Connect(function()
	Confirmation.InfoHolder.Visible = false
	Confirmation.FriendsList.Visible = true
end)

Confirmation.FriendsList.Cancel.MouseButton1Down:Connect(function()
	Confirmation.InfoHolder.Visible = true
	Confirmation.FriendsList.Visible = false
end)

-- Reset to default tab on close
Confirmation.Exit.MouseButton1Down:Connect(function()
	Confirmation.InfoHolder.Visible = true
	Confirmation.FriendsList.Visible = false
end)


--- Loading friends ---
local function FriendTemplate(Info)
	local Template = Dependency.PlayerTemplate:Clone()
	--Template:SetAttribute("UserId", Info.VisitorId)
	--Template:SetAttribute("PlaceId", Info.PlaceId)
	Template.PlayerName.Text = Info.UserName
	Template.DisplayName.Text = Info.DisplayName

	local CanFollowTo
	for Name, LocationInfo in pairs(Locations) do
		if LocationInfo.PlaceId == Info.PlaceId then
			CanFollowTo = Name
			break
		end
	end

	if CanFollowTo then
		local LocationInfo = Locations[CanFollowTo]

		Template.Status.Text = string.format("Online (%s)", LocationInfo.Alias or LocationInfo.Name)
		Template.LayoutOrder = LocationInfo.LayoutOrder
		Template.Join.Visible = true

	else
		Template.Status.Text = "Online"
		Template.LayoutOrder = 2
		Template.Join.Visible = false

	end

	Template.Join.MouseButton1Down:Connect(function()
		if TeleportDB then return end
		TeleportDB = true

		local Success, Error = Remotes.Teleport:InvokeServer(Info.PlaceId, Info.GameId)

		if not Success then
			Template.Join.Error.Visible = true
			task.wait(0.8)
			Template.Join.Error.Visible = false
		end

		TeleportDB = false

	end)

	Template.Parent = Confirmation.FriendsList.List
end


local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end


function Teleporting:RefreshFriends()
	for i, v in pairs(Confirmation.FriendsList.List:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	--local Success, FriendPages = pcall(function()
	--	return game:GetService("Players"):GetFriendsAsync(Paths.Player.UserId)
	--end)

	--local Friends = {}

	--if Success and FriendPages then
	--	for Friend, pageNo in iterPageItems(FriendPages) do
	--		table.insert(Friends, Friend)
	--	end

	--	local OnlineFriends = {}
	--	for i, Friend in pairs(Friends) do
	--		if Friend.IsOnline then
	--			table.insert(OnlineFriends, Friend)
	--		end
	--	end

	--	for i, v in pairs(OnlineFriends) do
	--		local placeId = nil
	--		local success, errorMessage = pcall(function()
	--			-- followId is the user ID of the player that you want to retrieve the place and job ID for
	--			currentInstance, _, placeId, jobId = TeleportService:GetPlayerPlaceInstanceAsync(followId)
	--		end)
	--	end
	--end

	local Success = pcall(function()
		local OnlineFriends = Paths.Player:GetFriendsOnline()

		for i, Friend in pairs(OnlineFriends) do
			FriendTemplate(Friend)
		end
	end)

	if not Success then
		task.wait(3)
		Teleporting:RefreshFriends()
	end
end


local Portals = Workspace:FindFirstChild("Portals")
if workspace:FindFirstChild("Portals") then
	for _, Portal in ipairs(Portals:GetChildren()) do
		local Location = Portal.Name

		local ProximityPrompt = Instance.new("ProximityPrompt")
		ProximityPrompt.HoldDuration = 0.25
		ProximityPrompt.MaxActivationDistance = 10
		ProximityPrompt.RequiresLineOfSight = false
		ProximityPrompt.ActionText = Location
		ProximityPrompt.Parent = Portal.PrimaryPart

		ProximityPrompt.Triggered:Connect(function(player)
			if player == game.Players.LocalPlayer and Paths.UI.Center.TeleportConfirmation.Visible == false and Paths.UI.Center.BuyEgg.Visible == false and game.Players.LocalPlayer:GetAttribute("BuyingEgg") == false then
				Teleporting:OpenConfirmation(Location)
				Paths.Modules.Buttons:UIOn(Paths.UI.Center.TeleportConfirmation,true)
			end

		end)

	end

end

coroutine.wrap(function()
	Teleporting:RefreshFriends()

	while task.wait(30) do
		Teleporting:RefreshFriends()
	end
end)()


return Teleporting