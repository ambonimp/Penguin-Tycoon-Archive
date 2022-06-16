local Feedback = {}

--- Dependencies ---
local Paths = require(script.Parent)
local Remotes = Paths.Remotes
local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")
local discord = require(script.Parent.Discord)

--- Members ---
local cachedPlayers = {}

--- CONSTANTS ---
local WEBHOOK_URL = "http://discord-proxy-1593185285.us-east-2.elb.amazonaws.com/api/webhooks/986357134033813534/_vaT5Z8HQqOXzoX_DElyyEt2Ig7tHeMiW6j0tLoX9E3wh_RMNXRhwlvqBM8TL0LOX8GT"
local AVATAR_URL_FORMAT = "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png"
local DEBOUNCING_TIME = 60*5
local MOODS = {
	["Bugs"] = {
		Emoji = ":bug:";
		Color = 0x9B59B6;
	};
	["Ideas"] = {
		Emoji = "💡";
		Color = 0x00FFFF;
	};
	["Meh"] = {
		Emoji = ":cry:";
		Color = 0xFF0000;
	};
	["Okay"] = {
		Emoji = ":neutral_face:";
		Color = 0x888888;
	};
	["Great"] = {
		Emoji = ":heart_eyes:";
		Color = 0x00FF00;
	};
}

Remotes.SendFeedback.OnServerInvoke = function(player, moodIndex, feedback, platform)
    if cachedPlayers[player.UserId] then
        if tick() - cachedPlayers[player.UserId] < DEBOUNCING_TIME then
            return false, "Please, wait 5 minutes before sending another feedback"
        end
    end

    -- Variables
    local username = player.Name
    local userId = player.UserId
    local avatarUrl = AVATAR_URL_FORMAT:format(userId)
    local mood = MOODS[moodIndex]
    local emoji = mood and mood.Emoji
    local color = mood and mood.Color
    local platform = platform or "Unknown"

    -- Create message
    local message = discord:NewMessage():SetUsername(username):SetAvatarUrl(avatarUrl)
    local embed = message:AddEmbed("Penguin Tycoon", feedback)

    if color then
        embed:SetColor(color)
    end

    if emoji then
        embed:AddField("Mood", emoji, true)
    end

    embed:AddField("User ID", tostring(userId), true)
    embed:AddField("Platform", platform, true)

    -- Send message
    local webhook = discord:NewWebhook(WEBHOOK_URL)
    webhook:Send(message)

    cachedPlayers[player.UserId] = tick()

    EventHandler:Fire("feedbackSent", player, {
        mood = moodIndex,
        platform = platform,
        place = "Tycoon"
    })

    return true, "Success!"
end

return Feedback