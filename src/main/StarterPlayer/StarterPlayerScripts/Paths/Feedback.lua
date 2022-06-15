local Feedback = {}

--- Dependencies ---
local Paths = require(script.Parent)
local Remotes = Paths.Remotes
local Modules = Paths.Modules
local DeviceDetector = Modules.DeviceDetector

--- Members ---
local feedbackUI:ImageLabel = Paths.UI.Center.Feedback
local infoHolder = feedbackUI.InfoHolder
local moods:Frame = infoHolder.Mood
local sendFeedbackButton:TextButton = infoHolder.Send
local selectedMoodButton:TextButton = nil
local feedbackTextBox:TextBox = infoHolder.TextFeedback
local sendFeedbackRemote:RemoteFunction = Remotes.SendFeedback
local notifyText:TextLabel = infoHolder.Notify
local debouncing = nil

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
    -- Simple deboucing to avoid too many requests
    if debouncing then
        if tick() - debouncing < 1 then
            return
        end
    end

    -- If no mood is selected then ignore
    if not selectedMoodButton then
        return
    end

    -- Get selected mood text
    local mood = selectedMoodButton.Parent.Name

    -- Get feedback text
    local feedbackText:string = feedbackTextBox.Text

    -- Does a trim in the feedback message
    if trimFeedbackText(feedbackText) == "" then
        return
    end

    -- Set the current debounce
    debouncing = tick()

    -- Does the server request to send the feedback
    local feedbackSent, message = sendFeedbackRemote:InvokeServer(mood, feedbackText, DeviceDetector:GetPlatform())
    feedbackTextBox.Visible = false

    -- Keep the message being displayed for 5 seconds
    delay(5, function()
        feedbackTextBox.Visible = true
    end)

    -- Update the message displayed in the screen to whether success or failure
    if feedbackSent then
       notifyText.TextColor3 = Color3.fromRGB(49, 255, 114) 
    else
        notifyText.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    notifyText.Text = message

    -- Clear mood selection and feedback text
    clearFeedback()
end

setupMoodSelection()
sendFeedbackButton.MouseButton1Click:Connect(sendFeedback)

return Feedback
