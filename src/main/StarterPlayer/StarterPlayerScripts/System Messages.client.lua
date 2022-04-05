local StarterGui = game:GetService("StarterGui")

local Messages = {
	"Group members get $5,000 Bonus Money!";
	"Group members get $5,000 Bonus Money!";
	"Have an idea for the game? You can suggest it at any of our social links!";
	"Support us by leaving a thumbs up!";
	"Follow us on social media for exclusive codes!";
	"Check out our Social Links at the bottom of the Game Page!";
	"Follow our twitter for a 10% income bonus!";
}

local function MakeMessage(Message, colour)
	StarterGui:SetCore("ChatMakeSystemMessage",{
		Text = Message;
		Color = colour;
		Font = Enum.Font.FredokaOne;
		FontSize = Enum.FontSize.Size28;
	})
end

MakeMessage("Welcome to Penguin Tycoon!")

--game:GetService("ReplicatedStorage").Remotes.MakeMessage.OnClientEvent:Connect(function(message, colour)
--	wait(3)
--	MakeMessage(message, colour)
--end)

while true do
	wait(600)
	local RandomMessage = Messages[Random.new():NextInteger(1, #Messages)]
	MakeMessage(RandomMessage, Color3.new(73/255, 155/255, 255/255))
end