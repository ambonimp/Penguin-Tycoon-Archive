local FuncLib = {}

function FuncLib.TableClone(t)
	local clone = {}

	for i, v in pairs(t) do
		clone[i] = v -- Need it simple
	end

	return clone
end

function FuncLib.ArrayFlip(t)
    local returning = {}

    for i = #t, 1, -1 do
        table.insert(returning, t[i])
    end

    return returning
end

function FuncLib.DictLength(t)
    local length = 0
    for _, _ in pairs(t) do
        length+= 1;
    end

    return length
end

function FuncLib.QuadraticBezier(t,p0,p1,p2)
	return (1-t)^2*p0+2*(1-t)*t*p1+t^2*p2
end

function FuncLib.DistanceBetween(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

function FuncLib.PlayerIsMoving(character)
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid.MoveDirection.Magnitude > 0 then
		return true
	end
end

function FuncLib.PlayerIsSwimming(character)
	if not character then return end
	local humanoid = character.Humanoid
	local state = humanoid:GetState()
	if humanoid and (state == Enum.HumanoidStateType.Swimming or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping) then
		return true
	end
end

function FuncLib.WithinFrame(obj, m)
	local tx = obj.AbsolutePosition.X
	local ty = obj.AbsolutePosition.Y
	local bx = tx + obj.AbsoluteSize.X
	local by = ty + obj.AbsoluteSize.Y
	if m.X >= tx and m.Y >= ty and m.X <= bx and m.Y <= by then
		return true
	end
end

function FuncLib.CursorWithinFrame(localPlayer, cursorPosition)
	local guiObjectNames = {
		TeleportConfirmation = true,
		Index = true,
		Penguins = true,
		Settings = true,
		Store = true,
		Tools = true,
		Pointer = true,
		Teleport = true,
		Codes = true, 
		Hide = true, 
	}
	
	local mouse = localPlayer:GetMouse()
	local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
	
	for _, v in pairs(playerGui:GetDescendants()) do
		if v:IsA("GuiObject") and guiObjectNames[v.Name] and v.Visible then
			if FuncLib.WithinFrame(v, mouse) then
				return true
			end
		end
	end
	
	return false
end

function FuncLib.SendMessage(Message, colour)
	local StarterGui = game:GetService("StarterGui")
	
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = Message,
		Color = colour,
		Font = Enum.Font.FredokaOne,
		FontSize = Enum.FontSize.Size12
	})
end

return FuncLib
