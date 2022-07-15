local Axe = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local TreeDetails = {
    ["Tree"] = {0,"Oak"},
    ["Oak"] = {500,"Birch"},
    ["Birch"] = {1500,"Spruce"},
    ["Spruce"] = {2500,"Acacia"},
    ["Acacia"] = {3000,"Jungle"},
    ["Jungle"] = {5000,"Blossom"},
    ["Blossom"] = {nil,nil},
}
if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
    TreeDetails = {
        ["Tree"] = {0,"Oak"},
        ["Oak"] = {5,"Birch"},
        ["Birch"] = {10,"Spruce"},
        ["Spruce"] = {15,"Acacia"},
        ["Acacia"] = {20,"Jungle"},
        ["Jungle"] = {25,"Blossom"},
        ["Blossom"] = {nil,nil},
    }
end
local Trees = {}
local HittingGrand = {}

function changeTransparency(model,t)
    if model then
        for i,v in pairs (model:GetChildren()) do
            if v:IsA("BasePart") then
                v.Transparency = t
                if v:GetAttribute("NoCollide") then
                    v.CanCollide = false
                else
                    v.CanCollide = t == 0
                end
            end
        end
    end
end

function Axe.GiveRandom(Player)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data == nil then return end
    local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
    local num = math.random(1,100)
    local reward = nil
    if num == 1 and Data["Outfits"]["Unicorn"] == nil then
        reward = {"Outfit"}
        Modules.Accessories:ItemAcquired(Player, "Unicorn", "Outfits")
    elseif num == 1 then
        reward = {"Gems",5}
        Modules.Income:AddGems(Player,5,"AxeAward")
    elseif num == 2 and Data["Accessories"]["Shark Hat"] == nil then
        reward = {"Outfit"}
        Modules.Accessories:ItemAcquired(Player, "Shark Hat", "Accessory")
    elseif num == 2 then
        reward = {"Gems",10}
        Modules.Income:AddGems(Player,5,"AxeAward") 
    elseif num <= 5 then
        print("Acorn")
        reward = {"Gems",5,"Acorn"}
        Modules.Income:AddGems(Player,5,"AxeAward")
    elseif num <= 13 then
        print("Money pouch")
        reward = {"Money",math.floor(10*PlayerIncome),"Pouch"}
        Modules.Income:AddMoney(Player,math.floor(10*PlayerIncome))
    elseif num <= 16.5 then
        print("Log")
        reward = {"Money",math.floor(20*PlayerIncome),"Log"}
        Modules.Income:AddMoney(Player,math.floor(20*PlayerIncome))
    end
    if reward then
        Remotes.Axe:FireClient(Player,reward,true)
    end
end


function ConnectTree(Tree)
    Trees[Tree] = true
    local w = 10
    if Tree.Name == "GrandTree" then
        w = 60
    end
    local c
    local lastChange = nil
    local max = Tree:GetAttribute("Health")
    c = Tree:GetAttributeChangedSignal("Health"):Connect(function()
        local h = Tree:GetAttribute("Health")
        if Tree.Name == "GrandTree" then
            local max = Tree:GetAttribute("MaxHealth")
            local per = math.floor(h/max*100)/100
            Tree.PrimaryPart.BillboardGui.Frame.Frame:TweenSize(UDim2.fromScale(per,1),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1,true)
            Tree.PrimaryPart.BillboardGui.Frame.Text.Text = h.." / "..max
        end
        local Day = os.date("%A")
        local Mult = 1
        --[[
        if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
            Mult = 2
        else
            Mult = 1
        end]]
        if h == 0 and Tree.Name == "GrandTree" then
            for v,amountofhits in pairs (HittingGrand) do
                pcall(function()
                    if game.Players:FindFirstChild(v) then
                        local Player = game.Players:FindFirstChild(v)
                        local Data = Modules.PlayerData.sessionData[Player.Name]
                        local Mult2 = 1
                        if Player:GetAttribute("Tool") == "Gold Axe" then
                            Mult2 = 2
                        end
                        if Tree.Name == "GrandTree" and Tree:GetAttribute("Health") == 0 then
                            if Data then
                                local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
                                local am = math.floor((PlayerIncome*(Mult*Mult2/10)))*amountofhits
                                
                                Modules.Income:AddMoney(Player,am)
                                Remotes.Axe:FireClient(Player,am,true)
                            elseif Player:GetAttribute("Income") then
                                local PlayerIncome = Player:GetAttribute("Income")
                                local am = math.floor((PlayerIncome*(Mult*Mult2/10)))*amountofhits
                                Modules.Income:AddMoney(Player,am)
                                Remotes.Axe:FireClient(Player,am,true)
                            end
                        end
                    end
                end)
            end
            HittingGrand = {}
            task.defer(function()
                for i = 59,0,-1 do
					if i < 10 then
						Tree.PrimaryPart.BillboardGui.Frame.Text.Text = "Respawning in: 0:0"..i
					else
						Tree.PrimaryPart.BillboardGui.Frame.Text.Text = "Respawning in: 0:"..i
					end
                    task.wait(1)
				end
				Tree.PrimaryPart.BillboardGui.Frame.Text.Text = "1000 / 1000"
            end)
        end
        lastChange = os.time()
        if h <= 0 then
            Tree.PrimaryPart.Down:Play()
            changeTransparency(Tree:FindFirstChild(1),1)
            changeTransparency(Tree:FindFirstChild(2),1)
            changeTransparency(Tree:FindFirstChild(3),0)
        elseif h > 1 and h < 3 then
            changeTransparency(Tree:FindFirstChild(1),1)
            changeTransparency(Tree:FindFirstChild(2),0)
            changeTransparency(Tree:FindFirstChild(3),1)
        end
        task.wait(w)
        if os.time()-lastChange > w-1 then
            Tree.PrimaryPart.Pop:Play()
            Tree:SetAttribute("Health",max) 
            changeTransparency(Tree:FindFirstChild(1),0)
            changeTransparency(Tree:FindFirstChild(2),1)
            changeTransparency(Tree:FindFirstChild(3),1)
        end
    end)

    Tree.AncestryChanged:Connect(function()
        Trees[Tree] = nil
        c:Disconnect()
    end)
    
end

--- Functions ---
function Axe.Equipped(player)
	Axe.LoadPlayer(player)
end

game.Players.PlayerRemoving:Connect(function(Player)
    if HittingGrand[Player.Name] then
        HittingGrand[Player.Name] = nil
    end
end)

function Axe.LoadPlayer(Player)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        local PlayerTycoon = Modules.Ownership:GetPlayerTycoon(Player)

        for tree,details in pairs (TreeDetails) do
            local treename = details[2]
            if table.find(Data["Woodcutting"].Unlocked,tree) then
                Player:SetAttribute("Tree"..tree,true)
            end
            if treename and table.find(Data["Woodcutting"].Unlocked,treename) then
                if PlayerTycoon.Tycoon:FindFirstChild(treename.." Bridge#1") and PlayerTycoon.Tycoon:FindFirstChild(treename.." Bridge#1"):FindFirstChild("Locked") then
                    PlayerTycoon.Tycoon:FindFirstChild(treename.." Bridge#1").Locked:Destroy()    
                end
            elseif treename then
                if PlayerTycoon.Tycoon:FindFirstChild(treename.." Bridge#1") and PlayerTycoon.Tycoon:FindFirstChild(treename.." Bridge#1"):FindFirstChild("Locked") then
                    local bb = PlayerTycoon.Tycoon:FindFirstChild(treename.." Bridge#1").Locked.PrimaryPart.BillboardGui
                    local per = math.floor(Data["Woodcutting"].Cut[tree]/details[1]*100)/100
                    if per < .15 then
                        per = .15
                    end
                    bb.Frame.Frame:TweenSize(UDim2.fromScale(per,1),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1,true)
    
                    bb.Frame.Text.Text = Data["Woodcutting"].Cut[tree].." / "..details[1]
                end
            end
        end
    end
end

function Axe.checkUnlocked(Player,TreeModel)
    if Player and TreeModel and TreeDetails[TreeModel.Name] then
        local Data = Modules.PlayerData.sessionData[Player.Name]
        if Data then
            
            local PlayerTycoon = Modules.Ownership:GetPlayerTycoon(Player)
            if Data["Woodcutting"].Cut[TreeModel.Name] then
				Data["Woodcutting"].Cut[TreeModel.Name] += 1
			else
				Data["Woodcutting"].Cut[TreeModel.Name] = 1
			end
            if TreeDetails[TreeModel.Name][1] and TreeDetails[TreeModel.Name][2] and not table.find(Data["Woodcutting"].Unlocked,TreeDetails[TreeModel.Name][2]) and Data["Woodcutting"].Cut[TreeModel.Name] >= TreeDetails[TreeModel.Name][1] then
                Player:SetAttribute("Tree"..TreeDetails[TreeModel.Name][2],true)
                table.insert(Data["Woodcutting"].Unlocked,TreeDetails[TreeModel.Name][2])
                if PlayerTycoon.Tycoon:FindFirstChild(TreeDetails[TreeModel.Name][2].." Bridge#1") and PlayerTycoon.Tycoon:FindFirstChild(TreeDetails[TreeModel.Name][2].." Bridge#1"):FindFirstChild("Locked") then
                    PlayerTycoon.Tycoon:FindFirstChild(TreeDetails[TreeModel.Name][2].." Bridge#1").Locked:Destroy()
                end
            elseif TreeDetails[TreeModel.Name][2] and TreeDetails[TreeModel.Name][1] then
	
                if PlayerTycoon.Tycoon:FindFirstChild(TreeDetails[TreeModel.Name][2].." Bridge#1") and PlayerTycoon.Tycoon:FindFirstChild(TreeDetails[TreeModel.Name][2].." Bridge#1"):FindFirstChild("Locked") then
                    local bb = PlayerTycoon.Tycoon:FindFirstChild(TreeDetails[TreeModel.Name][2].." Bridge#1").Locked.PrimaryPart.BillboardGui
                    local per = math.floor(Data["Woodcutting"].Cut[TreeModel.Name]/TreeDetails[TreeModel.Name][1]*100)/100
                    if per < .15 then
                        per = .15
                    end
                    bb.Frame.Frame:TweenSize(UDim2.fromScale(per,1),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1,true)
    
                    bb.Frame.Text.Text = Data["Woodcutting"].Cut[TreeModel.Name].." / "..TreeDetails[TreeModel.Name][1]
                end
            end
            
        end
    end
end

function Axe.canCut(Player,TreeModel)
    if Player and TreeModel and TreeDetails[TreeModel.Name] then
        local Data = Modules.PlayerData.sessionData[Player.Name]
        if Data then
            if table.find(Data["Woodcutting"].Unlocked,TreeModel.Name) then
                return true
            end
        end
    end
    return false
end

Remotes.Axe.OnServerEvent:Connect(function(Player,Tree)
    if not Axe.canCut(Player,Tree) then return end
    local dis = 14
    if Tree then
        dis = Tree.Name ~= "GrandTree" and 12 or 14
    end
    if Tree and Player.Character and Player.Character.PrimaryPart and Tree:GetAttribute("Health") > 0 and (Player.Character.PrimaryPart.Position-Tree.PrimaryPart.Position).magnitude < dis then
        if Trees[Tree] == nil then
            ConnectTree(Tree)
        end
        Tree:SetAttribute("Health",Tree:GetAttribute("Health") - 1) 
        if Tree:GetAttribute("Health") >= 0 then
            local Data = Modules.PlayerData.sessionData[Player.Name]
            local Day = os.date("%A")
            local Mult = 1
            --[[
            if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
                Mult = 2
            else
                Mult = 1
            end]]
            local Mult2 = 1
            if Player:GetAttribute("Tool") == "Gold Axe" then
                Mult2 = 2
            end
            local Div = Tree:GetAttribute("MaxHealth")
            if Tree.Name == "GrandTree" then
                Div = 50
                if HittingGrand[Player.Name] then
                    HittingGrand[Player.Name]+=1 
                else
                    HittingGrand[Player.Name] = 1
                end
            end
            if Tree:GetAttribute("Income") then
                Mult = Mult * Tree:GetAttribute("Income")
            end
            if Data then
				local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
                local added = math.floor((PlayerIncome*Mult*Mult2)/Div)
                if added < 10 then
                    added = 10
                end
                local mult = Paths.Modules.Pets.getBonus(Player,"Woodcutting","Income")
                added = math.floor(added*mult)
                Modules.Income:AddMoney(Player,added,true)
                Remotes.Axe:FireClient(Player,added)
            elseif Player:GetAttribute("Income") then
                local added = math.floor((Player:GetAttribute("Income")*Mult*Mult2)/Div)
                if added < 10 then
                    added = 10
                end
                local mult = Paths.Modules.Pets.getBonus(Player,"Woodcutting","Income")
                added = math.floor(added*mult)
                Modules.Income:AddMoney(Player,added,true)
                Remotes.Axe:FireClient(Player,added)
            end
            if Tree:GetAttribute("Health") == 0 then
                Axe.checkUnlocked(Player,Tree)
                Axe.GiveRandom(Player)
                Modules.Quests.GiveQuest(Player,"Collect","Woodcutting","Tree",1)
            end
        end
    end
end)


return Axe