local emotes = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local AllEmotes = require(Modules:WaitForChild("AllEmotes"))
local PropEmoteEvent = Remotes:WaitForChild("PropEmote")

local playerProps = {}
local LoadedAnims = {}
local Playing = {}

workspace:WaitForChild("Props").ChildAdded:Connect(function(object)
	if object:GetAttribute("Player") then
		playerProps[game.Players:FindFirstChild(object:GetAttribute("Player")).Name] = object
	end
	if object:GetAttribute("Time") then
		local t = object:GetAttribute("Time") or 7
		if t == 0 then
			t = 3
		end
		task.wait(7)
		if object then
			object:Destroy()
		end
	end
end)

PropEmoteEvent.OnServerEvent:Connect(function(Player,Emote,Kind)
	if LoadedAnims[Player.Name] == nil then
		LoadedAnims[Player.Name] = {}
	end
	local emote = AllEmotes.All[Emote]
	if emote.Prop and emote.PropFunction then
		if Kind == "Start" then
			if Playing[Player.Name] and LoadedAnims[Player.Name][Playing[Player.Name]] then
				LoadedAnims[Player.Name][Playing[Player.Name]]:Stop()
				LoadedAnims[Player.Name][Playing[Player.Name]] = nil
			end
			local newAnim = Instance.new("Animation")
			newAnim.AnimationId = "rbxassetid://"..emote.ID
			newAnim.Parent = Player
			LoadedAnims[Player.Name][Emote] = Player.Character.Humanoid.Animator:LoadAnimation(newAnim)
			Playing[Player.Name] = Emote
			newAnim:Destroy()
			local ended = emote.PropFunction(Player,LoadedAnims[Player.Name][Emote])
			if ended then
				Playing[Player.Name] = nil
				LoadedAnims[Player.Name][Emote] = nil
			end
		elseif LoadedAnims[Player.Name][Emote] then
			Playing[Player.Name] = nil
			LoadedAnims[Player.Name][Emote]:Stop()
			LoadedAnims[Player.Name][Emote] = nil
		end
	end
end)

game.Players.PlayerRemoving:Connect(function(Player)
	if LoadedAnims[Player.Name] then
		LoadedAnims[Player.Name] = {}
	end
	if playerProps[Player.Name] then
		playerProps[Player.Name]:Destroy()
		playerProps[Player.Name] = nil
	end
end)


return emotes
