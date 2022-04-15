local Client = {}

--Services
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Postie = require(game:GetService("ReplicatedStorage").VoldexAdmin.Libs.Postie)

--Extras
local MESSAGING_TOPIC = script.Parent:GetAttribute("Topic")
local BindableFunction = Instance.new("BindableFunction")
local PlayerGui = Players.LocalPlayer.PlayerGui

--UI
local VoldexAdmin = script.VoldexAdmin:Clone()
VoldexAdmin.Enabled = false
VoldexAdmin.Parent = PlayerGui
local ConfirmButton = VoldexAdmin.Main.Holder.Title.EnterBackground.Confirm
local EnterButton = VoldexAdmin.Main.Holder.Title.EnterBackground.Enter

local VoldexMessage = script.VoldexMessage
local currentTemplate = false

--Functions
function ReceiveMessage(Data)
	--Run the message with a Pcall (incase a developer makes a mistake sending an alert)
	local success, err
	success, err = pcall(function()
		local Title, Text, Accept, Deny, Duration, PlaceId, ShowOnlyOnPlaceId, Image =
			Data[1], Data[2], Data[3], Data[4], Data[5], Data[6], Data[7], Data[8]

		local function Attach()
			local Template = VoldexMessage:Clone()
			local rbxConnection

			local function destroyTemplate()
				Template:Destroy()
				rbxConnection:Disconnect()
				rbxConnection = nil
			end

			local function confirmTeleport()
				if PlaceId ~= nil then
					local success1, err1 = pcall(function() --Attempt to telport player if there is a placeid passed
						TeleportService:Teleport(tonumber(PlaceId))
					end)
					if err1 then
						warn(err1)
					end
				end
				destroyTemplate()
			end

			rbxConnection = UserInputService.InputBegan:Connect(function(Key)
				if Key.KeyCode == Enum.KeyCode.K or Key.KeyCode == Enum.KeyCode.DPadLeft then
					confirmTeleport()
				end

				if Key.KeyCode == Enum.KeyCode.L or Key.KeyCode == Enum.KeyCode.DPadRight then
					destroyTemplate()
				end
			end)

			--Make button teleport if PlaceId passed
			Template.Main.Accept.Button.Activated:Connect(function()
				confirmTeleport()
			end)

			Template.Main.Close.Button.Activated:Connect(function()
				destroyTemplate()
			end)

			Template.Main.Title.Close.Activated:Connect(function()
				destroyTemplate()
			end)

			--Add Image if sent
			if Image ~= nil then
				Template.Main.Img.Image = Image
			end

			local keyHintAccept = UserInputService.GamepadEnabled and "" or "(K)"
			local keyHintCancel = UserInputService.GamepadEnabled and "" or "(L)"

			Template.Main.Title.TextLabel.Text = Title
			Template.Main.Description.TextLabel.Text = Text
			Template.Main.Accept.Button.TextLabel.Text = ("%s %s"):format(keyHintAccept, Accept)
			Template.Main.Close.Button.TextLabel.Text = ("%s %s"):format(keyHintCancel, Deny)

			if UserInputService.GamepadEnabled then
				local leftDPad = Instance.new("ImageLabel")
				leftDPad.BackgroundTransparency = 1
				leftDPad.Position = UDim2.fromScale(0, 0)
				leftDPad.Size = UDim2.fromScale(0.240, 1)
				leftDPad.Image = "rbxassetid://8452608970"
				leftDPad.Parent = Template.Main.Accept.Button

				local rightDPad = Instance.new("ImageLabel")
				rightDPad.BackgroundTransparency = 1
				rightDPad.Position = UDim2.fromScale(0, 0)
				rightDPad.Size = UDim2.fromScale(0.240, 1)
				rightDPad.Image = "rbxassetid://8452610925"
				rightDPad.Parent = Template.Main.Close.Button
			end

			if Duration ~= nil then
				game:GetService("Debris"):AddItem(Template, tonumber(Duration))
			end

			Template.Parent = PlayerGui
		end

		--If the message should only be shown on one place (otherwise defaults to all)
		if ShowOnlyOnPlaceId ~= nil then
			if game.PlaceId == tonumber(ShowOnlyOnPlaceId) then
				Attach()
			end
		else
			Attach()
		end
	end)

	if err then
		warn(err)
	end
end
Postie.SetCallback("ReceiveMessage", ReceiveMessage)
-- Network:Bind("ReceiveMessage", ReceiveMessage) --Bind so the server can tell the client about the message

--Run when player hits send message button (grabs all values from frames)
function TrySendingMessage()
	--Loop through Frames, setting the values based on the frame names and textbox TEXT
	local Holder = VoldexAdmin.Main.Holder
	local FinalMessage = {}
	for _, Frame in pairs(Holder:GetChildren()) do
		if Frame:IsA("Frame") then
			FinalMessage[Frame.Name] = Frame.Background.TextBox.Text
		end
	end

	Postie.InvokeServer("SendMessage", 5, {
		FinalMessage["Title"],
		FinalMessage["Description"],
		FinalMessage["Accept"],
		FinalMessage["Decline"],
		FinalMessage["Duration"],
		FinalMessage["TeleportToPlaceID"],
		FinalMessage["ShowOnPlaceID"],
		FinalMessage["Img"],
	})
end

function IsAdmin()
	if Players.LocalPlayer:GetAttribute("Admin") == true then
		ConfirmButton.Visible = false
		VoldexAdmin.Enabled = true
		return true
	end
	VoldexAdmin.Enabled = false
	ConfirmButton.Visible = false
	return false
end

ConfirmButton.Activated:Connect(function()
	TrySendingMessage()
	VoldexAdmin.Enabled = false
	ConfirmButton.Visible = false
end)

--Sending Message Button/then close UI
EnterButton.Activated:Connect(function()
	ConfirmButton.Visible = not ConfirmButton.Visible
end)

--Press the close button/then close UI
VoldexAdmin.Main.Title.Close.Activated:Connect(function()
	VoldexAdmin.Enabled = false
end)

--Allow Clients to open the UI by accessing Console
UserInputService.InputBegan:Connect(function(Key)
	if Key.KeyCode == Enum.KeyCode.F8 then
		IsAdmin()
	end
end)

--Auto Enable Admin
--IsAdmin()
--Players.LocalPlayer:GetAttributeChangedSignal("Admin"):Connect(function()
--	IsAdmin()
--end)

return Client
