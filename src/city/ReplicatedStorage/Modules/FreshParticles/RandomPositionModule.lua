local module = {}

function module.RandomPosition(Part,WhatPartsPositionToChange)

	local XvectorMin = (Part.Position - (Part.Size / 2)).X
	local XvectorMax = (Part.Position + (Part.Size / 2)).X


	local YvectorMin = (Part.Position - (Part.Size / 2)).Y
	local YvectorMax = (Part.Position + (Part.Size / 2)).Y


	local ZvectorMin = (Part.Position - (Part.Size / 2)).Z
	local ZvectorMax = (Part.Position + (Part.Size / 2)).Z

	WhatPartsPositionToChange.CFrame = CFrame.new(math.random(XvectorMin,XvectorMax),math.random(YvectorMin,YvectorMax),math.random(ZvectorMin,ZvectorMax))
	return Part.Position
end

return module
