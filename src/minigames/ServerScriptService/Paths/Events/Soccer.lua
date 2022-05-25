local Soccer = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local blueteam = {}
local redteam = {}

function addGems(red,blue)
	for i,player in pairs (blueteam) do
		if game.Players:FindFirstChild(player) then
			Modules.Income:AddGems(game.Players:FindFirstChild(player), blue, "Soccer")
		end
	end
	for i,player in pairs (redteam) do
		if game.Players:FindFirstChild(player) then
			Modules.Income:AddGems(game.Players:FindFirstChild(player), red, "Soccer")
		end
	end
end

--- Event Functions ---
function Soccer:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	blueteam = {}
	redteam = {}
	
	for i = 1,math.floor(#Participants:GetChildren()/2) do
		local player = Participants:GetChildren()[i].Name
		table.insert(blueteam,player)
	end
	for i = math.floor(#Participants:GetChildren()/2)+1,#Participants:GetChildren() do
		local player = Participants:GetChildren()[i].Name
		table.insert(redteam,player)
	end

	for i,player in pairs (blueteam) do
		if game.Players:FindFirstChild(player) and game.Players:FindFirstChild(player).Character then
			local player = game.Players:FindFirstChild(player)
			local SpawnPos = Map.BlueSpawns:FindFirstChild(i).CFrame
			Remotes.Lighting:FireClient(player, "Soccer")
			local Character = Modules.Character:Spawn(player, SpawnPos)
			Character.Humanoid.WalkSpeed = 0

			Modules.Character:EquipShirt(player.Character,"Blue Jersey")
			
			Character:SetAttribute("Team","Blue")
		end
	end
	for i,player in pairs (redteam) do
		if game.Players:FindFirstChild(player) and game.Players:FindFirstChild(player).Character then
			local player = game.Players:FindFirstChild(player)
			local SpawnPos = Map.RedSpawns:FindFirstChild(i).CFrame
			Remotes.Lighting:FireClient(player, "Soccer")
			local Character = Modules.Character:Spawn(player, SpawnPos)
			Character.Humanoid.WalkSpeed = 0
			
			Modules.Character:EquipShirt(player.Character,"Red Jersey")
			
			Character:SetAttribute("Team","Red")
		end
	end

	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.Died:Connect(function()
				playerName:Destroy()
				if table.find(blueteam,playerName.Name) then
					table.remove(blueteam,table.find(blueteam,playerName.Name))
				elseif table.find(redteam,playerName.Name) then
					table.remove(redteam,table.find(redteam,playerName.Name))
				end
			end)
		end
	end

	addGems(2,2)
	
end

function Soccer:InitiateEvent(Event)
	local Map = workspace.Event["Event Map"]

	EventValues.TextToDisplay.Value = "Initiating Soccer..."

	Remotes.Events:FireAllClients("Initiate Event", Event)
end

function Soccer:StartEvent()
	local Map = workspace.Event["Event Map"]
	-- Activate Event
	Map.Active.Value = true
	local bluescore = 0
	local redscore = 0
	local velocity = 50
	local startCFrame = Map.PrimaryPart.Position+Vector3.new(0,16,0)
	Remotes.Events:FireAllClients("Event Started", "Soccer")
	local playerGoals = {}
	local StartTime = tick()
	local FinishTime = StartTime + Modules.EventsConfig["Soccer"].Duration
	EventValues.SoccerTime.Value = "03:00"
	EventValues.TextToDisplay.Value = "GO!!"
	wait(1)
	EventValues.TextToDisplay.Value = "Minigame in progress.."

	local function handleBall(ball)
		ball:SetNetworkOwner(nil)
		local db = {}
		ball.Touched:Connect(function(hit)
			if db[hit.Parent] == nil and hit.Parent and game.Players:GetPlayerFromCharacter(hit.Parent) then
				db[hit.Parent] = true
				ball.Parent.LastTouched.Value = hit.Parent
				if (hit.Parent.Humanoid.Jump or hit.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Jumping or hit.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall) then
					ball:ApplyImpulse(hit.Parent.HumanoidRootPart.CFrame.LookVector * velocity * ball:GetMass())
				else
					ball:ApplyImpulse(hit.Parent.HumanoidRootPart.CFrame.LookVector * velocity/10 * ball:GetMass())
				end
				Paths.Remotes.SoccerEvent:FireClient(game.Players:GetPlayerFromCharacter(hit.Parent),"hit",ball)
				wait(.5)
				db[hit.Parent] = nil
			end
		end)
		spawn(function()
			wait(2)
			if ball:IsDescendantOf(workspace) then
				ball:SetNetworkOwner(nil)
			end
		end)
	end
	
	for i,v in pairs (Map.Balls:GetChildren()) do
		local newBall = Paths.Services.RStorage.Assets.Balls.Ball:Clone()
		newBall:SetPrimaryPartCFrame(v.PrimaryPart.CFrame)
		newBall.Parent = Map.Balls
		handleBall(newBall.PrimaryPart)
		v:Destroy()
	end
	-- Give speed back to players
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 24
		end
	end
	
	-- Setup death part
	local TouchDb = {}
	
	local chances = {
		["Gold"] = 10,
		["Ball"] = 90,
	}
	
	local function removeBall(ball,team)
		if ball then
			if ball.LastTouched.Value then
				local data = Modules.PlayerData.sessionData[ball.LastTouched.Value.Name] 
				if data and ball.LastTouched.Value:GetAttribute("Team") == team then
					if data["Stats"]["Soccer"] then
						data["Stats"]["Soccer"] = data["Stats"]["Soccer"] + ball:GetAttribute("Score")
					else
						data["Stats"]["Soccer"] =  ball:GetAttribute("Score")
					end
				end
			end
			ball:Destroy()
		end
	end
	
	local function randomBallChance()
		local RandomNumber = math.random(1, 100)
		local Chosen = "Ball"
		local Number = 0
		for Ball, Chance in pairs(chances) do
			Number = Number + Chance
			if RandomNumber <= Number then
				Chosen = Ball
				break
			end
		end
		return Paths.Services.RStorage.Assets.Balls:FindFirstChild(Chosen):Clone()
	end
	
	local nextRandomBallTime = os.time()+math.random(10,20)
	local running = true
	
	local function confetti(Part)
		for i,v in pairs (Part:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(45)
			end
		end
	end
	
	local function netWorkowner()
		for i,model in pairs (Map.Balls:GetChildren()) do
			model.PrimaryPart:SetNetworkOwner(nil)
		end
	end
	
	--netWorkowner()
	
	local did10 = false
	
	repeat
		local justscoredother = false
		if os.time()>nextRandomBallTime and #Map.Balls:GetChildren() <= 2 then
			local ball = randomBallChance()
			ball.PrimaryPart.Position = startCFrame + Vector3.new(math.random(-20,20),10,math.random(-15,15))
			ball.Parent = Map.Balls
			nextRandomBallTime = os.time()+math.random(10,20)
		end
		
		local TimeLeft = math.floor((FinishTime - tick())*10)/10
		TimeLeft = string.format("%02i:%02i", TimeLeft/60%60, TimeLeft%60)
		
		for i,ball in pairs (Map.Balls:GetChildren()) do
			if ball.PrimaryPart.Position.Z > Map.RedGoal.PrimaryPart.Position.Z and not ball.PrimaryPart:GetAttribute("JustTP") then
				if Map.Cheering.Sound.IsPlaying == false then
					--Map.Cheering.Sound:Play()
				end
				confetti(Map.RedConfetti)
				ball.PrimaryPart:GetAttribute("JustTP",false)
				removeBall(ball,"Blue")
				if justscoredother then
					local ball = randomBallChance()
					ball.PrimaryPart.Position = startCFrame + Vector3.new(math.random(-20,20),15,0)
					ball.Parent = Map.Balls
					handleBall(ball.PrimaryPart)
				else
					local ball = randomBallChance()
					ball.PrimaryPart.Position = startCFrame + Vector3.new(math.random(-20,20),5,0)
					ball.Parent = Map.Balls
					handleBall(ball.PrimaryPart)
				end
				Remotes.SoccerEvent:FireAllClients("Scored","Blue")
				bluescore += ball:GetAttribute("Score")
				justscoredother = true
			elseif ball.PrimaryPart.Position.Z < Map.BlueGoal.PrimaryPart.Position.Z and not ball.PrimaryPart:GetAttribute("JustTP") then
				if Map.Cheering.Sound.IsPlaying == false then
					--Map.Cheering.Sound:Play()
				end
				confetti(Map.BlueConfetti)
				ball.PrimaryPart:SetAttribute("JustTP",true)
				removeBall(ball,"Red")
				if justscoredother then
					local ball = randomBallChance()
					ball.PrimaryPart.Position = startCFrame + Vector3.new(math.random(-20,20),15,0)
					ball.Parent = Map.Balls
					handleBall(ball.PrimaryPart)
				else
					local ball = randomBallChance()
					ball.PrimaryPart.Position = startCFrame + Vector3.new(math.random(-20,20),5,0)
					ball.Parent = Map.Balls
					handleBall(ball.PrimaryPart)
				end
				Remotes.SoccerEvent:FireAllClients("Scored","Red")
				redscore += ball:GetAttribute("Score")
				justscoredother = true
			end
		end
		
		Map.BlueScore.SurfaceGui.Frame.TextLabel.Text = bluescore
		Map.RedScore.SurfaceGui.Frame.TextLabel.Text = redscore
		
		EventValues.SoccerTime.Value = TimeLeft
		--netWorkowner() 
		task.wait(.2)	
		for i,ball in pairs (Map.Balls:GetChildren()) do
			ball:SetAttribute("JustTP",false)
		end
		if FinishTime-tick() <= 10 and did10 == false then
			did10 = true
			Map.Cheering.S10Sec:Play()
		end
		EventValues.ScoreRed.Value = redscore
		EventValues.ScoreBlue.Value = bluescore
	until tick() > FinishTime or bluescore >= 10 or redscore >= 10 or #Participants:GetChildren() == 0
	Map.Cheering.GameEnd:Play()
	local bluescore = bluescore
	local redscore = redscore
	local winners,text
	
	if redscore > bluescore then --red won
		winners = redteam
		confetti(Map.RedConfetti)
		text = "Red team won with a score of "..redscore.."!"
		Services.RStorage.Assets.RedChampion:Clone().Parent = Map
		Map.RedChampion.Name = "Winners"
		for i,player in pairs (blueteam) do
			if game.Players:FindFirstChild(player) and game.Players:FindFirstChild(player).Character and game.Players:FindFirstChild(player).Character.PrimaryPart then
				local player = game.Players:FindFirstChild(player)

				local SpawnPos = Map.BlueSpawns:FindFirstChild(i).CFrame
				player.Character:MoveTo(SpawnPos.Position)
			end
		end
		for i,player in pairs (redteam) do
			if game.Players:FindFirstChild(player) and game.Players:FindFirstChild(player).Character and game.Players:FindFirstChild(player).Character.PrimaryPart then
				local player = game.Players:FindFirstChild(player)
				player.Character:SetPrimaryPartCFrame(Map.Winners.Spawns:GetChildren()[i].CFrame)
			end
		end
		addGems(15,0)
	elseif redscore < bluescore then -- blue won
		winners = blueteam
		confetti(Map.BlueConfetti)
		text = "Blue team won with a score of "..bluescore.."!"
		Services.RStorage.Assets.BlueChampion:Clone().Parent = Map
		Map.BlueChampion.Name = "Winners"
		for i,player in pairs (redteam) do
			if game.Players:FindFirstChild(player) and game.Players:FindFirstChild(player).Character and game.Players:FindFirstChild(player).Character.PrimaryPart then
				local player = game.Players:FindFirstChild(player)

				local SpawnPos = Map.RedSpawns:FindFirstChild(i).CFrame
				player.Character:MoveTo(SpawnPos.Position)
			end
		end
		for i,player in pairs (blueteam) do
			if game.Players:FindFirstChild(player) and game.Players:FindFirstChild(player).Character and game.Players:FindFirstChild(player).Character.PrimaryPart then
				local player = game.Players:FindFirstChild(player)
				player.Character:SetPrimaryPartCFrame(Map.Winners.Spawns:GetChildren()[i].CFrame)
			end
		end
		addGems(0,15)
	elseif redscore == bluescore then -- tied
		winners = {unpack(blueteam),unpack(redteam)}
		text = "Both teams tied at "..redscore.."!"
		addGems(5,5)
	end

	Remotes.Events:FireAllClients("Event Ended","Soccer")
	if Map:FindFirstChild("Winners") then
		Map.Winners.Champion.Trophy.Cheering:Play()
		for i, Participant in pairs(Participants:GetChildren()) do
			local player = game.Players:FindFirstChild(Participant.Name)
			if player then
				Map.Balls:ClearAllChildren()
				Remotes.Events:FireClient(player, "Soccer Winners Camera", Map.Winners.CameraAngle.CFrame)
			end
		end
	end
	return winners,text
end

return Soccer