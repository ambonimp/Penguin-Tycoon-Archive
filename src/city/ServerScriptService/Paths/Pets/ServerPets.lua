local SeverPets ={}

local Paths = require(script.Parent.Parent)
local Modules = game:GetService("ReplicatedStorage").Modules
local PetPositions = workspace:WaitForChild("WorldPetsPosition")
local WorldPets = workspace:WaitForChild("WorldPets")
local TweenService = game:GetService("TweenService")
local PetDetails = require(Paths.Services.RStorage.Modules.PetDetails)

local Colors = {
    ["Panda"] = {"rbxassetid://9229750551","rbxassetid://9179182059","rbxassetid://9179195508"},
    ["Dog"] = {"rbxassetid://9172091357","rbxassetid://9229587298","rbxassetid://9172039791"},
    ["Cat"] = {"rbxassetid://9162792686","rbxassetid://9162806416","rbxassetid://9162805603"},
    ["Unicorn"] = {"rbxassetid://7680690881","rbxassetid://9228408892","rbxassetid://7680675885"},
    ["Dinosaur"] = {"rbxassetid://9186306556","rbxassetid://9186312021","rbxassetid://9229643838"},
    ["Rabbit"] = {"rbxassetid://9229893310","rbxassetid://9229885487","rbxassetid://9229900827"},
}

local nextAction = {}

function doAction(PetModel,action,Anims)
    if action == "Eat" then
        PetModel.PrimaryPart.ParticleEmitter:Emit(10)
        PetModel.PrimaryPart.Eat:Play()
        Anims["Jump"]:Play()
        task.wait(Anims["Jump"].Length*1.8)
        Anims["Jump"]:Stop()
    elseif action == "Trick" then
        PetModel.PrimaryPart.Trick:Play()
        Anims["Trick"]:Play()
        task.wait(Anims["Trick"].Length*.95)
        Anims["Trick"]:Stop()
    end
    nextAction[PetModel] = nil
end

Paths.Services.RStorage.Remotes.WorldPet.OnServerEvent:Connect(function(player,petmodel,kind)
    if nextAction[petmodel] then
        return
    else
        nextAction[petmodel] = kind
    end
end)

for i,Pet in pairs (PetPositions:GetChildren()) do
    local PetPart = Pet:FindFirstChild(Pet.Name)
    local Nodes = Pet.Nodes
    local Max = #Nodes:GetChildren()
    local running = true
    local PetModel = WorldPets:FindFirstChild(Pet.Name)
    local Anims = {}
    local TweenInfos = {}
    local Tweens = {}
    for i,v in pairs (PetModel.Animations:GetChildren()) do
        Anims[v.Name] = PetModel.AnimationController:LoadAnimation(v)
    end
    local FirstTime = true
    PetPart.Transparency = 1
    for i,v in pairs (Nodes:GetChildren()) do
        v.Transparency = 1
    end
    PetModel.PrimaryPart.TextureID = Colors[Pet.Name][math.random(1,3)]
    for i,sound in pairs (Paths.Services.RStorage.ClientDependency.Pets.PetSounds:GetChildren()) do
        local new = sound:Clone()
        new.Parent = PetModel.PrimaryPart
    end
    Paths.Services.RStorage.Assets.Hearts.ParticleEmitter:Clone().Parent = PetModel.PrimaryPart
    PetModel.PrimaryPart.Trick.SoundId = PetDetails[PetModel.Name].TrickSound
    task.spawn(function()
        while running do
            local n = 1
            if FirstTime then
                FirstTime = false
                n = math.random(1,Max)
            end
            for i = n,Max do
                if nextAction[PetModel] then
                    doAction(PetModel,nextAction[PetModel],Anims)
                end
                local timeDiff = math.random(2,15)/50
                local Action = Nodes:FindFirstChild(i)
                local TweenInfo = TweenInfos[i] or TweenInfo.new(Action:GetAttribute("Time")-timeDiff)
                local Tween = Tweens[i] or TweenService:Create(PetPart,TweenInfo,{CFrame = Action.CFrame})
                if Tweens[i] == nil then
                    TweenInfos[i] = TweenInfo
                    Tweens[i] = Tween 
                end
                Tween:Play()
                if Action:GetAttribute("Anim") and Anims[Action:GetAttribute("Anim")]  then
                    local prev = i - 1
                    if prev < 1 then
                        prev = Max
                    end
                    if Nodes:FindFirstChild(prev) and Nodes:FindFirstChild(prev):GetAttribute("Anim") ~= Action:GetAttribute("Anim") then
                        Anims[Action:GetAttribute("Anim")]:Play()
                    elseif Nodes:FindFirstChild(prev) == nil then
                        Anims[Action:GetAttribute("Anim")]:Play()
                    end
                end
				task.wait(Action:GetAttribute("Time")-timeDiff)
                if Action:GetAttribute("Anim") and Anims[Action:GetAttribute("Anim")]  then
                    local num = i+1
                    if num > Max then
                        i = 1
                    end
                    local next = Nodes:FindFirstChild(num)
                    if next and next:GetAttribute("Anim") ~= Action:GetAttribute("Anim") then
                        Anims[Action:GetAttribute("Anim")]:Stop()
                    elseif next == nil then
                        Anims[Action:GetAttribute("Anim")]:Stop()
                    end
                end
            end
        end
    end)
end

return SeverPets

