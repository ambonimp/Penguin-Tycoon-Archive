local Verification = {}



--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Other Variables ---
local verificationUI = Paths.UI.Center.Codes.Verification
local isVerified = Remotes.GetStat:InvokeServer("Twitter Verification")



--- Functions ---
local function SetVerified()
	isVerified = true

	verificationUI.TextBox.TextBox.Text = "10% Bonus Active"
	verificationUI.TextBox.TextBox.TextColor3 = Color3.fromRGB(28, 255, 47)
	verificationUI.TextBox.UIStroke.Color = Color3.fromRGB(28, 255, 47)
	verificationUI.Verify.Title.Text = "Verified"
	verificationUI.Verify.BackgroundColor3 = Color3.fromRGB(28, 255, 47)
	verificationUI.Verify.UIStroke.Color = Color3.fromRGB(28, 255, 47)
end

if isVerified then SetVerified() end


verificationUI.Verify.MouseButton1Down:Connect(function()
	if not isVerified then
		local success, response = Remotes.Verification:InvokeServer(verificationUI.TextBox.TextBox.Text)
		
		if success then SetVerified() end
		
		verificationUI.TextBox.TextBox.Text = response or "Error, try again later!"
		
		wait(1.5)
		verificationUI.TextBox.TextBox.Text = ""
	else
		verificationUI.TextBox.TextBox.Text = "Already verified!"
		wait(1.5)
		SetVerified()
	end
end)


return Verification