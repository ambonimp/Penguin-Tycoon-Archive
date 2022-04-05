local AudioHandler = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Audio Variables ---
local AllAudio = Paths.Player.PlayerScripts:WaitForChild("Audio")

local CurrentSong = 0


--- Audio Functions ---

-- Playing all main tracks on loop
local function UpdateSong()
	if Modules.Lighting.CurrentLocation == "Night Skating" then
		if CurrentSong == 4 then CurrentSong = 0 end
		CurrentSong += 1

		local Source = Modules.Audio:PlayMusic(AllAudio, tostring(CurrentSong))
		wait(Source.TimeLength - 5)

	elseif Modules.Audio.Music[Modules.Lighting.CurrentLocation] then
		local Source = Modules.Audio:PlayMusic(AllAudio, Modules.Lighting.CurrentLocation)
		wait(Source.TimeLength - 5)
	end
end


function AudioHandler:LocationChanged(Location)
	coroutine.wrap(function()
		UpdateSong()
	end)()
end


coroutine.wrap(function()
	while true do
		UpdateSong()
		wait()
	end
end)()


function AudioHandler:ItemPurchased()
	local Sound = Modules.Audio:GetSound(Modules.Audio.NEW_PURCHASE, AllAudio, 0.3, 1)
	Sound.Playing = false
	Sound:Play()
end


-- Clicking Buttons Sound
local ButtonClick = Modules.Audio:GetSound(Modules.Audio.BUTTON_CLICKED, AllAudio, 0.2)

for i, v in pairs(Paths.Player.PlayerGui:GetDescendants()) do
	if string.match(v.ClassName, "Button") then
		v.MouseButton1Down:Connect(function()
			ButtonClick:Play()
		end)
	end
end


return AudioHandler