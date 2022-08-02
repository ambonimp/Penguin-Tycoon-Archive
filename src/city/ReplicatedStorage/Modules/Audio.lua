local Audio = {}

Audio.Music = {
	["Coffee Shop"] = "rbxassetid://9733752764",
	["School"] = "rbxassetid://9733753368",
	["Diner"] = "rbxassetid://9733754139",
	["Penguin City"] = {"rbxassetid://9789033755", "rbxassetid://9789029867", "rbxassetid://9789024459", "rbxassetid://9789015804"};
	["Nightclub"] = {"rbxassetid://9738071306","rbxassetid://9738070672","rbxassetid://9738070355","rbxassetid://9738069435"};
}

Audio.NEW_PURCHASE = "rbxassetid://8192378886"
Audio.BUTTON_CLICKED = "rbxassetid://8192378506"
Audio.HEART_RECEIVED = "rbxassetid://8192378647"
Audio.ITEM_COLLECTED = "rbxassetid://8192378776"

local Current = {
	["Penguin City"] = math.random(1,#Audio.Music["Penguin City"])-1,
	["Nightclub"] = math.random(1,#Audio.Music["Nightclub"])-1
}

function getRandomSong(Music)
	if type(Audio.Music[Music]) == "string" then
		return Audio.Music[Music]
	elseif type(Audio.Music[Music]) == "table" then
		local total = #Audio.Music[Music]
		if Current[Music] then
			Current[Music] += 1
			if Current[Music] > total then
				Current[Music] = 1
			end
		end
		return Audio.Music[Music][Current[Music]]
	end
end

function Audio:PlayMusic(Source, Music)
	if Source:FindFirstChild("Music") then
		for i = 0.2, 0, -0.02 do
			Source.Music.Volume = i
			task.wait()
		end
		local getId = getRandomSong(Music)
		Source.Music.Volume = 0
		Source.Music.TimePosition = 0
		Source.Music.SoundId = getId
		Source.Music:Play()

		for i = 0, 0.2, 0.01 do
			Source.Music.Volume = i
			task.wait()
		end

	elseif not Source:FindFirstChild("Music") then
		local getId = getRandomSong(Music)
		local Sound = Instance.new("Sound")
		Sound.Volume = 0
		Sound.Looped = true
		Sound.Name = "Music"
		Sound.SoundId = getId
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