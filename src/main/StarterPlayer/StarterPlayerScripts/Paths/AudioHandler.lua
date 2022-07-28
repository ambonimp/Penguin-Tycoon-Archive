local AudioHandler = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Audio Variables ---
local AllAudio = Paths.Player.PlayerScripts:WaitForChild("Audio")

local CurrentSong = false


--- Audio Functions ---

-- Playing all main tracks on loop
task.spawn(function()
--[[
	local StartingSong = Random.new():NextInteger(1, 4)
	
	for i = StartingSong, 4, 1 do
		local Source = Modules.Audio:PlayMusic(AllAudio, tostring(i))
		task.wait(Source.TimeLength - 5)
	end *]]
	
	while true do
		for i = 1, 4, 1 do
			Modules.Audio:PlayMusic(AllAudio, tostring(i))
		end
		
		task.wait()
	end

end)


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