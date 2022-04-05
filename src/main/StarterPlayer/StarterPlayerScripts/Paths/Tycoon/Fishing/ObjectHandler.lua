local replicatedStorage = game:GetService("ReplicatedStorage")

local ObjectHandler = {}

function ObjectHandler.CreateBopper(character)
	local hrp = character:WaitForChild("HumanoidRootPart")
	
	if not hrp:FindFirstChild("Attachment") then
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(0, 2, 0)
		attachment.Name = "PlayerAttachment"
		attachment.Parent = hrp
	end
	
	local tool = character:WaitForChild("Tool")
	local tip = tool.Tip
	
	local bobber = replicatedStorage.Bobber:Clone()
	bobber.Parent = workspace
	bobber:PivotTo(CFrame.new(hrp.Position + Vector3.new(0, 7, 0)))
	
	
	bobber.PrimaryPart:FindFirstChild("Rope").Attachment1 = tip.Attachment

	return bobber
end

return ObjectHandler
