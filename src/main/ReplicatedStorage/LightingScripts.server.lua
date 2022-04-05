local folder = game.ReplicatedStorage.Lighting["Tycoon"]

for i, v in pairs(folder:GetChildren()) do
	if v.Name ~= "Lighting" then
		v:Destroy()
	else
		for i, v in pairs(v:GetChildren()) do
			v.Value = game.Lighting[v.Name]
		end
	end

	for i, v in pairs(game.Lighting:GetChildren()) do
		v:Clone().Parent = folder
	end
end