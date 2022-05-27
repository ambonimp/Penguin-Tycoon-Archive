local RPModule = require(script:WaitForChild("RandomPositionModule"))
local TS = game:GetService("TweenService")
local Particle = {}
Particle.__index = Particle

function Particle.new(
	EmissionPart,
	Color,
	Size,
	Amount,
	ImageID,
	TrailEnabled,
	TrailLength,
	LightEnabled,
	LightEmission,
	Lifetime,
	Collisions,
	ExtraWeight,
	EasingStyle,
	Speed,
	RotSpeed,
	Offset,
	ParticlePart
)
	local newParticle = {
		EmissionPart = EmissionPart;
		Color = Color;
		Size = Size;
		Amount = Amount;
		ImageID = ImageID;
		TrailEnabled = TrailEnabled;
		LightEmission = LightEmission;
		TrailLength = TrailLength;
		LightEnabled = LightEnabled;
		Lifetime = Lifetime;
		Collisions = Collisions;
		ExtraWeight = ExtraWeight;
		EasingStyle = EasingStyle;
		Speed = Speed,
		RotSpeed = RotSpeed,
		Offset = Offset,
		ParticlePart = ParticlePart
	}
	HomeFolder = Instance.new("Folder",workspace)
	HomeFolder.Name = "Particles"
	setmetatable(newParticle, Particle)

	return newParticle
end

function Particle:Spawn()
	for i = 1,self.Amount do
		local Part = self.ParticlePart:Clone() or game:GetService("ReplicatedStorage").Assets:WaitForChild("Particle"):Clone()

		---
		
		Part.Parent = HomeFolder
		RPModule.RandomPosition(self.EmissionPart,Part)
		Part.Position = Part.Position + (self.Offset or Vector3.new(0,0,0))
		Part.Trail.Color = ColorSequence.new(self.Color)
		Part.Image.ImageLabel.ImageColor3 = self.Color

		Part.Size = Vector3.new(self.Size,self.Size,self.Size)
		Part.Image.Size = UDim2.new(self.Size,0,self.Size,0)
		
		if self.ImageID then
			Part.Image.ImageLabel.Image = self.ImageID
		end
		
		if self.TrailEnabled then
			Part.Trail.Enabled = true
			Part.Trail.LightEmission = self.LightEmission
			Part.Trail.Lifetime = self.TrailLength
		else
			Part.Trail.Enabled = false
		end
		if self.LightEnabled then
			Part.PointLight.Enabled = true
			Part.PointLight.Color = self.Color
		else
			Part.PointLight.Enabled = false
		end

		if not self.Collisions then
			Part.CanCollide = false
		end
		

		Part.BodyForce.Force = Vector3.new(0,-self.ExtraWeight,0)

		
		--Part.Color = self.Color
		Part.Velocity = Vector3.new(
			math.random(-self.Speed,self.Speed),
			self.Speed,
			math.random(-self.Speed,self.Speed)
		)
		Part.BodyAngularVelocity.AngularVelocity = Vector3.new(
			math.random(-self.RotSpeed,self.RotSpeed),
			math.random(-self.RotSpeed,self.RotSpeed),
			math.random(-self.RotSpeed,self.RotSpeed)
		)
		TS:Create(
			Part.Trail,
			TweenInfo.new(
				self.Lifetime,
				self.EasingStyle
			),
			{
				Lifetime = 0
			}
		):Play()

		TS:Create(
			Part,
			TweenInfo.new(
				self.Lifetime,
				self.EasingStyle
			),
			{
				Size = Vector3.new(0,0,0)
			}
		):Play()
		TS:Create(
			Part.PointLight,
			TweenInfo.new(
				self.Lifetime,
				self.EasingStyle
			),
			{
				Range = 0;
				Brightness = 0
			}
		):Play()
		game:GetService("Debris"):AddItem(Part,self.Lifetime)
	end
end

return Particle