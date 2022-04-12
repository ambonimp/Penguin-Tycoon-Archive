local Audio = {}

Audio.Music = {
	["Egg Hunt"] = "rbxassetid://1839336610";
	["Soccer"] = "rbxassetid://9281853936";
	["Skate Race"] = "rbxassetid://9281859168";
	["Falling Tiles"] = "rbxassetid://9281853936";
	["1"] = "rbxassetid://9283373303";
	["2"] = "rbxassetid://9062549990"; 
	["3"] = "rbxassetid://9062555894"; 
	["4"] = "rbxassetid://9062575526"; 
	["5"] = "rbxassetid://9062580741";  
}

Audio.NEW_PURCHASE = "rbxassetid://8192378886"
Audio.BUTTON_CLICKED = "rbxassetid://8192378506"
Audio.HEART_RECEIVED = "rbxassetid://8192378647"
Audio.ITEM_COLLECTED = "rbxassetid://8192378776"

Audio.SkateRaceLap = "rbxassetid://8680469472"
Audio.SkateRaceCountdown = "rbxassetid://8680468629"


function Audio:PlayMusic(Source, Music)
	if Source:FindFirstChild("Music") and Source.Music.SoundId ~= Audio.Music[Music] then
		for i = 0.2, 0, -0.02 do
			Source.Music.Volume = i
			task.wait()
		end

		Source.Music.Volume = 0
		Source.Music.TimePosition = 0
		Source.Music.SoundId = Audio.Music[Music]
		Source.Music:Play()

		for i = 0, 0.2, 0.01 do
			Source.Music.Volume = i
			task.wait()
		end
		
	elseif not Source:FindFirstChild("Music") then
		local Sound = Instance.new("Sound")
		Sound.Volume = 0
		Sound.Looped = true
		Sound.Name = "Music"
		Sound.SoundId = Audio.Music[Music]
		Sound.Parent = Source
		Sound:Play()

		for i = 0, 0.2, 0.01 do
			Sound.Volume = i
			task.wait()
		end
	end
	
	return Source.Music
end

function Audio:GetSound(ID, Source, Volume, PlaybackSpeed, StartPosition)
	local Sound = Source:FindFirstChild(tostring(ID))
	
	if not Sound then
		Sound = Instance.new("Sound")
		Sound.Volume = Volume or 0.5
		Sound.PlaybackSpeed = PlaybackSpeed or 1
		Sound.Name = ID
		Sound.SoundId = ID
		Sound.Parent = Source
	end
	
	Sound.TimePosition = StartPosition or 0
	
	return Sound
end

return Audio