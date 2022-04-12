local EggHunt = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Votes = Services.RStorage.Modules.EventsConfig.Votes

local EventInfoUI = Paths.UI.Top.EventInfo
local EventVotingUI = Paths.UI.Top.EventVoting
local EventPromptUI = Paths.UI.Top.EventPrompt
local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs["Egg Hunt"]



--- Event Functions ---
function EggHunt:EventStarted()
	if Participants:FindFirstChild(Paths.Player.Name) then
		local Map = workspace.Event["Event Map"]

		EventInfoUI.ExitEvent.Visible = true
		EventUI.Visible = true
	end
end


function EggHunt.InitiateEvent()
	
end

function EggHunt.EventEnded()

end

--- Event Updating ---
function EggHunt:UpdateEvent(Info)
	
end


return EggHunt