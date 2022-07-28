local TweenService = game:GetService("TweenService")
local Audio = {}

Audio.Music = {
	["1"] = "rbxassetid://9789033755";
	["2"] = "rbxassetid://9789029867";
	["3"] = "rbxassetid://9789024459";
	["4"] = "rbxassetid://9789015804";
}

Audio.NEW_PURCHASE = "rbxassetid://8192378886"
Audio.BUTTON_CLICKED = "rbxassetid://8192378506"
Audio.HEART_RECEIVED = "rbxassetid://8192378647"
Audio.ITEM_COLLECTED = "rbxassetid://8192378776"

local FADE_DURATION = 0.1

function Audio:PlayMusic(Source, Music)
	local Sound = Source:FindFirstChild("Music")
	if not Sound then
		Sound = Instance.new("Sound")
		Sound.Name = "Music"
		Sound.SoundId = Audio.Music[Music]
		Sound.Looped = false
		Sound.Parent = Source
	end

	Sound.Volume = 0
	Sound.TimePosition = 0
	Sound.SoundId = Audio.Music[Music]
	Sound:Play()

	local Length
	repeat
		task.wait()
		Length = Sound.TimeLength
	until Length ~= 0
	local FadeLength = Length * FADE_DURATION

	-- Fade in
	TweenService:Create(Sound, TweenInfo.new(FadeLength, Enum.EasingStyle.Linear), {Volume = 0.2}):Play()
	task.wait(Length - FadeLength)

	TweenService:Create(Sound, TweenInfo.new(FadeLength, Enum.EasingStyle.Linear), {Volume = 0}):Play()
	task.wait(FadeLength)

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