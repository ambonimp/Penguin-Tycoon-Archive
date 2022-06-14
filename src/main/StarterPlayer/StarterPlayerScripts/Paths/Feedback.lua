local Feedback = {}

--- Dependencies ---
local Paths = require(script.Parent)
local Remotes = Paths.Remotes

--- Members ---
local feedbackUI:ImageLabel = Paths.UI.Center.Feedback
local infoHolder = feedbackUI.InfoHolder
local moods:Frame = infoHolder.Mood
local sendFeedbackButton:TextButton = infoHolder.Send
local selectedMoodButton:TextButton = nil
local feedbackTextBox:TextBox = infoHolder.TextFeedback
local sendFeedbackRemote:RemoteFunction = Remotes.SendFeedback
local notifyText:TextLabel = infoHolder.Notify

--- CONSTANTS ---
local MOOD_COLOR_DEFAULT = Color3.fromRGB(85, 199, 255)
local MOOD_COLOR_SELECTED = Color3.fromRGB(130, 255, 96)

local function selectMood(button:TextButton)
    if selectedMoodButton then
        selectedMoodButton.BackgroundColor3 = MOOD_COLOR_DEFAULT
    end

    button.BackgroundColor3 = MOOD_COLOR_SELECTED
    selectedMoodButton = button
end

local function setupMoodSelection()
    for _, mood in moods:GetChildren() do
       if mood:IsA("Frame") then
            local textButton:TextButton = mood.Button
            textButton.MouseButton1Click:Connect(function()
                selectMood(textButton)
            end)
       end 
    end
end

local function trimFeedbackText(str): string
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

local function clearFeedback()
    selectedMoodButton.BackgroundColor3 = MOOD_COLOR_DEFAULT
    selectedMoodButton = nil
    feedbackTextBox.Text = ""
end

local function sendFeedback()
    if not selectedMoodButton then
        return
    end

    local mood = selectedMoodButton.Parent.Name
    local feedbackText:string = feedbackTextBox.Text

    if trimFeedbackText(feedbackText) == "" then
        return
    end

    local feedbackSent, message = sendFeedbackRemote:InvokeServer(mood, feedbackText)
    feedbackTextBox.Visible = false
    delay(60, function()
        feedbackTextBox.Visible = true
        feedbackUI.Visible = false
    end)

    if feedbackSent then
       notifyText.TextColor3 = Color3.fromRGB(49, 255, 114) 
    else
        notifyText.TextColor3 = Color3.fromRGB(255, 0, 0)
    end

    notifyText.Text = message
    clearFeedback()
end

setupMoodSelection()
sendFeedbackButton.MouseButton1Click:Connect(sendFeedback)

return Feedback
