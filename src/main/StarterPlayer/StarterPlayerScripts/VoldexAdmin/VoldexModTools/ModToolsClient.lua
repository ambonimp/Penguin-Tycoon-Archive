-- Init module
local ModToolsClient = {}

--\\ Services //--
local Players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")

--\\ Dependencies //--
local Postie = require(game.ReplicatedStorage.VoldexAdmin.Libs.Postie)
local VoldexMiddleware = require(game.ReplicatedStorage.VoldexAdmin.VoldexMiddleware)

--\\ Members //--
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local listPlayersUi: ScreenGui
local promptFrame: Frame
local baseFrame: Frame
local isClosing = false
local rows = {}

local function notify(success: boolean, message: string)
	local notificationGui = Instance.new("ScreenGui")
	local success = pcall(function()
		notificationGui.Parent = PlayerGui

		local notificationFrame = Instance.new("Frame")
		notificationFrame.Size = UDim2.fromScale(1, 0.10)
		notificationFrame.Position = UDim2.fromScale(0, 1)
		notificationFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		notificationFrame.Parent = notificationGui
		notificationFrame:TweenPosition(UDim2.fromScale(0, 0), nil, nil, 1)

		local notificationLabel = Instance.new("TextBox")
		notificationLabel.Name = "name"
		notificationLabel.ClearTextOnFocus = false
		notificationLabel.TextEditable = false
		notificationLabel.Size = UDim2.fromScale(1, 0.365)
		notificationLabel.Position = UDim2.fromScale(0.016, 0.35)
		notificationLabel.Font = Enum.Font.GothamBlack
		notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationLabel.TextScaled = true
		notificationLabel.Text = ("%s: %s"):format(success and "Success" or "Failed", message)
		notificationLabel.BackgroundTransparency = 1
		notificationLabel.BorderSizePixel = 0
		notificationLabel.Parent = notificationFrame

		wait(3)
		notificationGui:Destroy()
	end)

	if not success then
		notificationGui:Destroy()
	end
end

local function banPlayer(player: Player, reason): string
	local success, response = Postie.InvokeServer("RequestBan", 5, player, reason)
	if success then
		if response then
			notify(response.success, response.message)
		else
			notify(false, "API call failed")
		end
	end
end

local function getPlayerAvatar(player: Player): string
	-- Fetch the thumbnail
	local userId = player.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	return content
end

local function createButton(label: string, isPrimary: boolean): ImageButton
	local button = Instance.new("ImageButton")
	button.Image = "rbxassetid://8263972983"
	button.HoverImage = "rbxassetid://8263973344"
	button.PressedImage = "rbxassetid://8263973616"
	button.ImageColor3 = isPrimary and Color3.fromRGB(49, 226, 144) or Color3.fromRGB(226, 226, 226)
	button.ScaleType = Enum.ScaleType.Slice
	button.SliceCenter = Rect.new(156, 129, 920, 290)
	button.SliceScale = 1
	button.BackgroundTransparency = 1
	button.Size = UDim2.fromScale(0.368, 0.407)
	button.Name = label

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(0.8, 0.6)
	textLabel.Position = UDim2.fromScale(0.5, 0.55)
	textLabel.Font = Enum.Font.LuckiestGuy
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Text = label
	textLabel.Parent = button

	return button
end

local function promptBan(player: Player)
	baseFrame:TweenPosition(UDim2.fromScale(baseFrame.Position.X.Scale, 1), nil, nil, 0.3)

	promptFrame = Instance.new("Frame")
	promptFrame.Position = UDim2.fromScale(0.291, 0.328)
	promptFrame.Size = UDim2.fromScale(0.429, 0.419)
	promptFrame.BorderSizePixel = 5
	promptFrame.Name = "Prompt Ban"
	promptFrame.Parent = listPlayersUi

	local promptHeader = Instance.new("Frame")
	promptHeader.AutoLocalize = false
	promptHeader.Name = "Header"
	promptHeader.Size = UDim2.fromScale(1, 0.137)
	promptHeader.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	promptHeader.Parent = promptFrame

	local promptBody = Instance.new("Frame")
	promptBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	promptBody.AutoLocalize = false
	promptBody.Size = UDim2.fromScale(1, 1 - promptHeader.Size.Y.Scale)
	promptBody.Position = UDim2.fromScale(0, promptHeader.Size.Y.Scale)
	promptBody.Name = "Body"
	promptBody.Parent = promptFrame

	local promptLabel = Instance.new("TextBox")
	promptLabel.Name = "name"
	promptLabel.ClearTextOnFocus = false
	promptLabel.TextEditable = false
	promptLabel.Size = UDim2.fromScale(0.941, 0.165)
	promptLabel.Position = UDim2.fromScale(0.016, 0)
	promptLabel.Font = Enum.Font.GothamBlack
	promptLabel.TextColor3 = Color3.fromRGB(58, 58, 58)
	promptLabel.TextScaled = true
	promptLabel.Text = ("Reason for Banning %s (%d):"):format(player.Name, player.UserId)
	promptLabel.BackgroundTransparency = 1
	promptLabel.BorderSizePixel = 0
	promptLabel.Parent = promptBody

	local promptInput = Instance.new("TextBox")
	promptInput.Name = "Input"
	promptInput.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
	promptInput.BackgroundTransparency = 0
	promptInput.BorderSizePixel = 0
	promptInput.Size = UDim2.fromScale(0.972, 0.459)
	promptInput.Position = UDim2.fromScale(0.01, 0.178)
	promptInput.Font = Enum.Font.Gotham
	promptInput.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	promptInput.PlaceholderText = "Please describe in detail the reason for banning. . ."
	promptInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	promptInput.TextScaled = false
	promptInput.TextSize = 22
	promptInput.TextXAlignment = Enum.TextXAlignment.Left
	promptInput.TextYAlignment = Enum.TextYAlignment.Top
	promptInput.Text = ""
	promptInput.AutoLocalize = false
	promptInput.MultiLine = true
	promptInput.TextWrapped = true
	promptInput.ClearTextOnFocus = false
	promptInput.Parent = promptBody

	local promptHeaderAvatar = Instance.new("ImageLabel")
	promptHeaderAvatar.Name = "avatar"
	promptHeaderAvatar.BorderSizePixel = 0
	promptHeaderAvatar.BackgroundTransparency = 1
	promptHeaderAvatar.Size = UDim2.fromScale(0.126, 1.715)
	promptHeaderAvatar.Position = UDim2.fromScale(0.421, -0.915)
	promptHeaderAvatar.Image = getPlayerAvatar(player)
	promptHeaderAvatar.SizeConstraint = Enum.SizeConstraint.RelativeXY
	promptHeaderAvatar.Parent = promptHeader

	local btnConfirm = createButton("CONFIRM", true)
	btnConfirm.Position = UDim2.fromScale(0.064, 0.77)
	btnConfirm.Size = UDim2.fromScale(0.418, 0.151)
	btnConfirm.Parent = promptBody

	local btnCancel = createButton("CANCEL", false)
	btnCancel.Position = UDim2.fromScale(0.525, 0.77)
	btnCancel.Size = UDim2.fromScale(0.418, 0.151)
	btnCancel.Parent = promptBody

	local function closePrompt()
		baseFrame.Visible = true
		promptFrame:Destroy()
		promptFrame = nil
		baseFrame:TweenPosition(UDim2.fromScale(baseFrame.Position.X.Scale, 0.08), nil, nil, 0.3)
	end

	btnConfirm.MouseButton1Click:Connect(function()
		if isClosing then
			return
		end

		ModToolsClient.CloseScreenGui()
		banPlayer(player, promptInput.Text)
	end)

	btnCancel.MouseButton1Click:Connect(function()
		closePrompt()
	end)
end

local function fillList(players: table, body: Frame)
	local function createRow(player)
		local row = Instance.new("Frame")
		row.Name = player.Name
		row.Size = UDim2.new(1, 0, 0, 100)
		row.BackgroundColor3 = Color3.fromRGB(245, 244, 241)
		row.BorderSizePixel = 0
		row.Parent = body
		row:SetAttribute("id", player.UserId)
		row:SetAttribute("DisplayName", player.DisplayName)

		local content = getPlayerAvatar(player)

		local avatar = Instance.new("ImageLabel")
		avatar.Name = "avatar"
		avatar.BorderSizePixel = 0
		avatar.BackgroundTransparency = 1
		avatar.Size = UDim2.fromScale(0.715, 0.715)
		avatar.Position = UDim2.fromScale(0.022, 0.095)
		avatar.Image = content
		avatar.SizeConstraint = Enum.SizeConstraint.RelativeYY
		avatar.Parent = row

		local textName = Instance.new("TextBox")
		textName.Name = "name"
		textName.TextEditable = false
		textName.ClearTextOnFocus = false
		textName.Size = UDim2.fromScale(0.368, 0.226)
		textName.Position = UDim2.fromScale(0.103, 0.353)
		textName.Font = Enum.Font.GothamBlack
		textName.TextColor3 = Color3.fromRGB(58, 58, 58)
		textName.TextScaled = true
		textName.Text = ("%s  [ ID: %d ]"):format(player.DisplayName, player.UserId)
		textName.BackgroundTransparency = 1
		textName.BorderSizePixel = 0
		textName.Parent = row

		local textUser = Instance.new("TextBox")
		textUser.Name = "user"
		textUser.TextEditable = false
		textUser.ClearTextOnFocus = false
		textUser.Size = UDim2.fromScale(0.245, 0.213)
		textUser.Position = UDim2.fromScale(0.156, 0.597)
		textUser.Font = Enum.Font.Gotham
		textUser.TextColor3 = Color3.fromRGB(58, 58, 58)
		textUser.TextScaled = true
		textUser.Text = ("@%s"):format(player.Name)
		textUser.BackgroundTransparency = 1
		textUser.BorderSizePixel = 0
		textUser.TextXAlignment = Enum.TextXAlignment.Left
		textUser.Parent = row

		local btnBan = createButton("BAN PLAYER", true)
		btnBan.Position = UDim2.fromScale(0.591, 0.251)
		btnBan.Parent = row

		btnBan.MouseButton1Click:Connect(function()
			if isClosing then
				return
			end

			if promptFrame then
				promptFrame:Destroy()
			end

			promptBan(player)
		end)

		table.insert(rows, row)
	end

	for _, player in pairs(players) do
		if player ~= Players.LocalPlayer then
			createRow(player)
		end
	end
end

local function createScreenGui()
	if isClosing then
		return
	end

	listPlayersUi = Instance.new("ScreenGui")
	listPlayersUi.Name = "AdminListPlayers"
	listPlayersUi.AutoLocalize = false
	listPlayersUi.IgnoreGuiInset = true
	listPlayersUi.Parent = PlayerGui

	local overlay = Instance.new("TextButton")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromScale(0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.3
	overlay.AutoButtonColor = false
	overlay.Parent = listPlayersUi

	baseFrame = Instance.new("Frame")
	baseFrame.AutoLocalize = false
	baseFrame.Size = UDim2.fromScale(0.5, 0.7)
	baseFrame.Position = UDim2.fromScale(0.25, 1)
	baseFrame.Name = "ModToolsGui"
	baseFrame.Parent = listPlayersUi
	baseFrame:TweenPosition(UDim2.fromScale(baseFrame.Position.X.Scale, 0.08), nil, nil, 0.3)

	local header = Instance.new("Frame")
	header.AutoLocalize = false
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.113)
	header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	header.Parent = baseFrame

	local searchInput = Instance.new("TextBox")
	searchInput.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
	searchInput.PlaceholderText = "Search..."
	searchInput.Text = ""
	searchInput.Font = Enum.Font.GothamBlack
	searchInput.TextSize = 22
	searchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchInput.Size = UDim2.fromScale(0.351, 0.652)
	searchInput.Position = UDim2.fromScale(0.1, 0.248)
	searchInput.Parent = header
	searchInput.Changed:Connect(function(property)
		if property == "Text" then
			local searchFor = searchInput.Text
			for _, row in pairs(rows) do
				if string.upper(row.Name:sub(1, searchFor:len())) ~= string.upper(searchFor)
				and string.sub(row:GetAttribute("id"), 1, searchFor:len()) ~= searchFor
				and string.upper(string.sub(row:GetAttribute("DisplayName"), 1, searchFor:len())) ~= string.upper(searchFor)
				then
					row.Visible = false
				else
					row.Visible = true
				end
			end
		end
	end)

	local closeButton = Instance.new("ImageButton")
	closeButton.Image = "rbxassetid://7948049127"
	closeButton.HoverImage = "rbxassetid://7950065386"
	closeButton.PressedImage = "rbxassetid://7940009950"
	closeButton.Size = UDim2.fromScale(1, 1)
	closeButton.Position = UDim2.fromScale(0.942, -0.495)
	closeButton.Name = "CloseButton"
	closeButton.BackgroundTransparency = 1
	closeButton.Parent = header

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = closeButton

	local body = Instance.new("ScrollingFrame")
	body.AutoLocalize = false
	body.Size = UDim2.fromScale(1, 1 - header.Size.Y.Scale)
	body.Position = UDim2.fromScale(0, header.Size.Y.Scale)
	body.Name = "Body"
	body.CanvasSize = UDim2.new(0, 0, 0, 0)
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.Parent = baseFrame

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uiListLayout.Parent = body

	closeButton.MouseButton1Click:Connect(function()
		if isClosing then
			return
		end
		overlay:Destroy()
		ModToolsClient.CloseScreenGui()
	end)

	fillList(Players:GetPlayers(), body)
end

function ModToolsClient.CloseScreenGui()
	if isClosing then
		return
	end

	isClosing = true
	baseFrame:TweenPosition(UDim2.fromScale(baseFrame.Position.X.Scale, 1), nil, nil, 0.3)
	wait(0.5)
	listPlayersUi:Destroy()
	listPlayersUi = nil
	rows = {}
	promptFrame = nil
	isClosing = false
end

-- Handles the keybind to open and close the menu
local function onInputBegan(input: InputObject, gpe: any)
	-- Check for Game Processed Event, which means if this input was programmatically requested
	if gpe then
		return
	end

	-- Check for Admin Input
	if
		input.KeyCode == Enum.KeyCode.Comma
		and (userInputService:IsKeyDown(Enum.KeyCode.LeftShift) or userInputService:IsKeyDown(Enum.KeyCode.RightShift))
	then
		if not listPlayersUi then
			createScreenGui()
		else
			ModToolsClient.CloseScreenGui()
		end
	end
end

-- Returns true if the local player is an authorized moderator
local function authorized(): boolean
	return VoldexMiddleware.IsPlayerAuthorized(Players.LocalPlayer)
end

-- Start
function ModToolsClient.Start()
	if not authorized() then
		script:Destroy()
		return false
	end

	userInputService.InputBegan:Connect(onInputBegan)

	-- createScreenGui()

	return true
end

return ModToolsClient
