-- Save lighting
local folder = game.ReplicatedStorage.LightingPresets["Falling Tiles"]

for i, v in pairs(folder:GetChildren()) do
	if v.Name ~= "Lighting" then
		v:Destroy()
	else
		for i, v in pairs(v:GetChildren()) do
			v.Value = game.Lighting[v.Name]
		end
	end
end

for i, v in pairs(game.Lighting:GetChildren()) do
	v:Clone().Parent = folder
end



-- Load lighting
local preset = game.ReplicatedStorage.LightingPresets["Night Skating"]
game.Lighting:ClearAllChildren()

for i, v in pairs(preset:GetChildren()) do
	if not v:IsA("Folder") then
		v:Clone().Parent = game.Lighting
	else
		for i, v in pairs(v:GetChildren()) do
			if game.Lighting[v.Name] then
				game.Lighting[v.Name] = v.Value
			end
		end 
	end
end

local preset = game.ReplicatedStorage.LightingPresets["Falling Tiles"]
game.Lighting:ClearAllChildren()

for i, v in pairs(preset:GetChildren()) do
	if not v:IsA("Folder") then
		v:Clone().Parent = game.Lighting
	else
		for i, v in pairs(v:GetChildren()) do
			if game.Lighting[v.Name] then
				game.Lighting[v.Name] = v.Value
			end
		end 
	end
end