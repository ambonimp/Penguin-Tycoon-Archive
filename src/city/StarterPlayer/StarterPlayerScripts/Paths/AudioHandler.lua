local AudioHandler = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local ReplicatedStorage = Services.RStorage
local Zone = require(ReplicatedStorage.Modules:WaitForChild("Zone"))

--- Audio Variables ---
local AllAudio = Paths.Player.PlayerScripts:WaitForChild("Audio")

local CurrentLocation = "Penguin City"

--- Audio Functions ---

-- Playing all main tracks on loop
local function UpdateSong()
	if Modules.Audio.Music[CurrentLocation] then
		local Source = Modules.Audio:PlayMusic(AllAudio, CurrentLocation)
		task.wait(Source.TimeLength - 2.5)
	end
end


function AudioHandler:LocationChanged(Location)
	CurrentLocation = Location
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


Remotes.Lighting.OnClientEvent:Connect(function(Location)
	AudioHandler:LocationChanged(Location)
end)


task.spawn(function()
	repeat task.wait(1) until #workspace.MusicZones:GetChildren() == 4
	task.wait(1)
	for i,v in pairs (workspace.MusicZones:GetChildren()) do
		if v:IsA("Folder") then
			local container = v
			for i,v in pairs (container:GetChildren()) do
				v.Transparency = 1
			end
			local zone = Zone.new(container)
			local db = false
			zone.partEntered:Connect(function(p)
				if p and p.Parent and p.Name == "HumanoidRootPart" then
					local plr = game.Players:FindFirstChild(p.Parent.Name)
					if plr == game.Players.LocalPlayer then
						if db then return end
						db = true
						if v.Name ~= CurrentLocation then
							AudioHandler:LocationChanged(v.Name)
						end
						task.wait(.2)
						db = false
					end
				end
			end)
			
			zone.partExited:Connect(function(p)
				if p and p.Parent and p.Name == "HumanoidRootPart" then
					local plr = game.Players:FindFirstChild(p.Parent.Name)
					if plr == game.Players.LocalPlayer then
						if db then return end
						db = true
						AudioHandler:LocationChanged("Penguin City")
						task.wait(.2)
						db = false
					end
				end
			end)
		end
	end
end)



return AudioHandler