local Boat = {}


function Boat:Setup(Model)
	-- Variables
	local Seat = Model.DriverSeat
	local Prompt = Seat.ProximityPrompt
	local Power = Model:GetAttribute("Power")

	local PreviousOccupant = nil
	
	-- Animations
	local Animations = Model:FindFirstChild("Animations")
	local MainAnimIsPlaying = false
	local MainAnim = nil

	if Animations then
		MainAnim = Model.AnimationController.Animator:LoadAnimation(Animations.Main)
	end
	
	-- Prompt to sit player as driver
	Prompt.Triggered:Connect(function(Player)
		if Seat.Occupant == nil then
			local Char = Player.Character
			if Char then
				local Humanoid = Char:FindFirstChild("Humanoid")
				if Humanoid then
					Seat:Sit(Humanoid)
				end
			end
		end
	end)
	
	-- Main function
	Seat.Changed:Connect(function(Property)
		if not Model:FindFirstChild("MainPart") then return end

		-- Change steerangle if going backwards
		local SteerAngle = -1
		if Seat.Throttle <= 0 then
			if Model:FindFirstChild("BoatBehind") then
				for i,v in pairs (Model.BoatBehind:GetChildren()) do
					if v:IsA("ParticleEmitter") or v:IsA("Trail") then
						v.Enabled = false
					end
				end
			end
			if Seat.Throttle < 0 then
				SteerAngle = 1
			end
		else
			if Model:FindFirstChild("BoatBehind") then
				for i,v in pairs (Model.BoatBehind:GetChildren()) do
					if v:IsA("ParticleEmitter") or v:IsA("Trail") then
						v.Enabled = true
					end
				end
			end
		end
		-- Apply forces
		Model.MainPart.AngularVelocity.AngularVelocity = Vector3.new(0, SteerAngle * Seat.Steer, 0)
		Model.MainPart.BodyForce.Force = Seat.CFrame.LookVector * Power * Seat.Throttle

		-- Playing animations
		if Seat.Throttle > 0 and MainAnim then
			if not MainAnimIsPlaying then
				MainAnimIsPlaying = true
				MainAnim:Play()
			end
		elseif MainAnim then
			if MainAnimIsPlaying then
				MainAnimIsPlaying = false
				MainAnim:Stop(2)
			end
		end

		if Property == "Occupant" then
			Model.MainPart.Anchored = false
			-- Make previous occupant no longer massless
			if PreviousOccupant then
				for i, v in pairs(PreviousOccupant) do
					if v:IsA("BasePart") then
						v.Massless = false
					end
				end

				PreviousOccupant = nil
			end

			-- Make new occupant massless
			if Seat.Occupant ~= nil then
				local Hum = Seat.Occupant
				local Char = Hum.Parent
				local Player = game.Players:GetPlayerFromCharacter(Char)
				Player:SetAttribute("Vehicle",Model.Name)
				Prompt.Enabled = false

				if Player and Char then
					local Root = Char:FindFirstChild("HumanoidRootPart")

					if Root then
						PreviousOccupant = {}

						Root.Anchored = true

						for i, v in pairs(Char:GetChildren()) do
							if v:IsA("BasePart") then
								if v.Massless == false then
									v.Massless = true
									table.insert(PreviousOccupant, v)
								end
							end
						end

						Root.Anchored = false
					end
				end
				
			-- if occupant is nil (aka player just left the boat) then
			else
				task.wait(2)
				if Seat.Occupant == nil then
					Model.MainPart.Anchored = true
					Model.MainPart.AngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
					Model.MainPart.BodyForce.Force = Vector3.new(0,0,0)
					for i,v in pairs (Model:GetDescendants()) do
						if v:IsA("BasePart") then
							v.AssemblyLinearVelocity = Vector3.new(0,0,0)
							v.AssemblyAngularVelocity = Vector3.new(0,0,0)
						end
					end
					Prompt.Enabled = true
				end

			end

		end

	end)

end


return Boat