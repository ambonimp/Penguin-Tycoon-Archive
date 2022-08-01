local Teleporting = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Variables ---
local TeleportButton = UI.Right.Buttons.Teleport
local Confirmation = UI.Center.TeleportConfirmation

local TeleportDB = false

local Locations = {
	[7967681044] = {PlaceId = 7951464846}, -- Night Skating -> Tycoon
	[7951464846] = {PlaceId = 7967681044} -- Tycoon -> Night Skating
}
local TestingLocations = {
	[9118436978] = {PlaceId = 9170899192}, -- Night Skating -> Tycoon
	[9170899192] = {PlaceId = 9118436978} -- Tycoon -> Night Skating
}
local QALocations = {
	[9170919040] = {PlaceId = 9118461324}, -- Night Skating -> Tycoon
	[9118461324] = {PlaceId = 9170919040} -- Tycoon -> Night Skating
}

local IsTesting = (game.GameId == 3425588324)
if IsTesting then Locations = TestingLocations end
local IsQA = (game.GameId == 3425594443)
if IsQA then Locations = QALocations end

--- Functions ---
function Teleporting:TeleportTo(PlaceId)
	if TeleportDB then return end
	TeleportDB = true

	local Success, Error = Remotes.TeleportExternal:InvokeServer(PlaceId)
	
	if not Success then
		warn(Error)
		Confirmation.InfoHolder.Confirm.Error.Visible = true
		task.wait(0.8)
		Confirmation.InfoHolder.Confirm.Error.Visible = false
	end
	TeleportDB = false
end

-- Confirmation UI buttons
Confirmation.InfoHolder.Confirm.MouseButton1Down:Connect(function()
	Teleporting:TeleportTo(Modules.PlaceIds["Penguin City"])
end)

--Confirmation.Cancel.MouseButton1Down:Connect(function()
--	Confirmation.Visible = false
--end)


--- Switching between tabs ---
Confirmation.InfoHolder.Friends.MouseButton1Down:Connect(function()
	Confirmation.InfoHolder.Visible = false
	Confirmation.FriendsList.Visible = true
end)

Confirmation.FriendsList.Cancel.MouseButton1Down:Connect(function()
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
	
	if Info.PlaceId == 7967681044 or Info.PlaceId == 8359572680 then
		Template.Status.Text = "Online (Skating)"
		Template.LayoutOrder = 0
		Template.Join.Visible = true
	elseif Info.PlaceId == 7951464846 or Info.PlaceId == 8241346678 then
		Template.Status.Text = "Online (Tycoon)"
		Template.LayoutOrder = 1
		Template.Join.Visible = true
	else
		Template.Status.Text = "Online"
		Template.LayoutOrder = 2
		Template.Join.Visible = false
	end
	
	Template.Join.MouseButton1Down:Connect(function()
		if TeleportDB then return end
		TeleportDB = true
		
		local Success, Error = Remotes.TeleportExternal:InvokeServer(Info.PlaceId, Info.GameId)

		if not Success then
			Template.Join.Error.Visible = true
			wait(0.8)
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
		wait(2)
		Teleporting:RefreshFriends()
	end
end

local ProximityPrompt
--[[
if workspace:FindFirstChild("Portals") then
	ProximityPrompt = workspace.Portals.Portal.PrimaryPart.ProximityPrompt
elseif Paths.Tycoon then
	ProximityPrompt = Paths.Tycoon:WaitForChild("PenguinCity").PrimaryPart.ProximityPrompt
end

if ProximityPrompt then
	ProximityPrompt.Triggered:Connect(function(player)
		if player == game.Players.LocalPlayer and Paths.UI.Center.TeleportConfirmation.Visible == false and Paths.UI.Center.BuyEgg.Visible == false and game.Players.LocalPlayer:GetAttribute("BuyingEgg") == false then
			Teleporting:OpenConfirmation()
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.TeleportConfirmation,true)
		end
	end)
end
]]
--[[ if Paths.Tycoon then
	local BillBoard = Paths.Tycoon:WaitForChild("Board")
	local UI = BillBoard.PrimaryPart.SurfaceGui
	UI.Parent = Paths.Player.PlayerGui
	UI.Adornee = BillBoard.PrimaryPart
	UI.Confirm.MouseButton1Down:Connect(function()
		Teleporting:OpenConfirmation()
		Paths.Modules.Buttons:UIOn(Paths.UI.Center.TeleportConfirmation,true)
	end)
end
--]]

coroutine.wrap(function()
	Teleporting:RefreshFriends()
	
	while wait(30) do
		Teleporting:RefreshFriends()
	end
end)()


return Teleporting