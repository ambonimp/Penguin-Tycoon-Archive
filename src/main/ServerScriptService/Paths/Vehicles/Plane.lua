local Plane = {}


function Plane:Setup(Model)
	local Owner = game.Players:FindFirstChild(Model.Parent.Parent.Owner.Value)
	local seat = Model.DriverSeat
	local bottom = Model:WaitForChild("MainPart")
	local old = nil

	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local new = seat.Occupant
		if new then
			new = game.Players:GetPlayerFromCharacter(new.Parent)
			if Model.Name == "Jet" then
				new:SetAttribute("Vehicle","Robux Plane")
			else
				new:SetAttribute("Vehicle","Plane")
			end
			bottom.Anchored = false
			seat:SetNetworkOwner(new)
			bottom:SetNetworkOwner(new)
			old = new
		elseif old then
			old:SetAttribute("Vehicle","None")
			bottom:SetNetworkOwner(nil)
			Model.MainPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Model.MainPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Model:GetDescendants()
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			local raycastResult = workspace:Raycast(Model.PrimaryPart.Position-Vector3.new(0,2,0), Vector3.new(0,-5,0), raycastParams)
		
			if raycastResult then
				bottom.Anchored = true
			else
				local t = 0
				repeat raycastResult = workspace:Raycast(Model.PrimaryPart.Position-Vector3.new(0,2,0), Vector3.new(0,-5,0), raycastParams) task.wait(.25) t += .25 until t > 7 or raycastResult or seat.Occupant

				if seat.Occupant == nil then
					bottom.Anchored = true
				end
			end
			
		end
	end)


	local prompt = seat.ProximityPrompt
	local sit = seat
	sit.Disabled = true

	prompt.Triggered:Connect(function(player)
		if player == Owner then
			sit.Disabled = false
			local char = workspace:WaitForChild(player.Name)
			local hum = char.Humanoid
			sit:Sit(hum)
			prompt.Enabled = false
			while sit.Occupant do
				task.wait(1)
			end
			prompt.Enabled = true
			sit.Disabled = true
		end
	end)

	sit:GetPropertyChangedSignal("Disabled"):Connect(function()
		if sit.Disabled == true then
			prompt.Enabled = true
		end
	end)


	sit:GetPropertyChangedSignal("Occupant"):Connect(function()
		if sit.Occupant == nil then
			prompt.Enabled = true
		end
	end)

end


return Plane