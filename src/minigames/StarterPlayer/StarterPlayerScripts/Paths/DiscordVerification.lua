local Verification = {}



--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Other Variables ---
local verificationUI = Paths.UI.Center.Codes.Verification2
local isVerified = Remotes.GetStat:InvokeServer("Discord Verification")
local db = false



--- Functions ---

-- Set the UI to display as already verified
local function SetVerified()
	isVerified = true

	verificationUI.TextBox.TextBox.Text = "Verified"
	verificationUI.TextBox.TextBox.TextColor3 = Color3.fromRGB(28, 255, 47)
	verificationUI.TextBox.UIStroke.Color = Color3.fromRGB(28, 255, 47)
	verificationUI.Verify.Title.Text = "Verified"
	verificationUI.Verify.BackgroundColor3 = Color3.fromRGB(28, 255, 47)
	verificationUI.Verify.UIStroke.Color = Color3.fromRGB(28, 255, 47)
end

if isVerified then SetVerified() end


-- Verify button function
verificationUI.Verify.MouseButton1Down:Connect(function()
	if db then return end
	db = true
	
	if not isVerified then
		local inputtedUsername = verificationUI.TextBox.TextBox.Text
		
		verificationUI.TextBox.TextBox.Text = "Checking username..."
		wait(0.5) -- manual small wait so it's not too fast and the player know it's being checked
		local success, response = Remotes.DiscordVerification:InvokeServer(inputtedUsername)
		verificationUI.TextBox.TextBox.Text = response or "Error, try again later!"
		wait(1.5)
		if success then SetVerified() end
	else
		verificationUI.TextBox.TextBox.Text = "Already verified!"
		wait(1.5)
		SetVerified()
	end
	
	db = false
end)

return Verification