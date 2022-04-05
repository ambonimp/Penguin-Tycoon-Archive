local CharacterSelect = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

--local PlayerImage = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
local CurrentChar = "Penguin"
	
	
--- UI Variables ---
--local SelectionUI = UI.CharacterSelect
--local SwapButton = UI.Center:WaitForChild("Penguins"):WaitForChild("List"):WaitForChild("Player"):WaitForChild("SwapCharacter")


--- Functions ---
function CharacterSelect:SpawnCharacter(Type)
	--if Type == "Avatar" then -- Change to penguin icon
	--	--SwapButton.BackgroundColor3 = Color3.fromRGB(82, 164, 240)
	--	--SwapButton.UIStroke.Color = Color3.fromRGB(82, 164, 240)
	--	--SwapButton.Icon.Image = "rbxassetid://7706198060"
	--	SwapButton.TheText.Text = "Penguin"
		
	--elseif Type == "Penguin" then -- Change to avatar 
	--	--SwapButton.BackgroundColor3 = Color3.fromRGB(59, 193, 49)
	--	--SwapButton.UIStroke.Color = Color3.fromRGB(59, 193, 49)
	--	--SwapButton.Icon.Image = PlayerImage
	--	SwapButton.TheText.Text = "Avatar"
		
	--end
	
	--CurrentChar = Type
	--Remotes.SpawnCharacter:FireServer(Type)
	Remotes.SpawnCharacter:FireServer("Penguin")
	
	--SelectionUI.Parent.Visible = false
end

function CharacterSelect:Respawn()
	CharacterSelect:SpawnCharacter(CurrentChar)
end


----- Spawning Character ---
--SelectionUI:WaitForChild("Avatar").MouseButton1Down:Connect(function()
--	CharacterSelect:SpawnCharacter("Avatar")
--end)

--SelectionUI:WaitForChild("Penguin").MouseButton1Down:Connect(function()
--	CharacterSelect:SpawnCharacter("Penguin")
--end)


----- Swapping Character Button ---
--local SwapDB = false


--SwapButton.MouseButton1Down:Connect(function()
--	if SwapDB then return end
--	SwapDB = true
	
--	if CurrentChar == "Avatar" then
--		CharacterSelect:SpawnCharacter("Penguin")
--	else
--		CharacterSelect:SpawnCharacter("Avatar")
--	end
	
--	task.wait(2.5)
--	SwapDB = false
--end)


return CharacterSelect