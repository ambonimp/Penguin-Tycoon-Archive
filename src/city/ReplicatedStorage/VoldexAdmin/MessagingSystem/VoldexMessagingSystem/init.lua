local RunService = game:GetService("RunService")
if RunService:IsServer() then
    print("Loaded server module for Voldex Messaging System")
	return require(script.ServerMessageSystem)
else
    print("Loaded client module for Voldex Messaging System")
	return require(script.ClientMessageSystem)
end
