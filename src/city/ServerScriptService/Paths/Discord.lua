---
---Discord API by FoxbyDev
---https://github.com/FoxbyDev/RbxLua-Discord-Wrapper/blob/master/main.lua
---
---@class Discord
---
local Discord = {}

-- Sub Classes
local Message = {} ---@class DiscordMessage
local Embed = {} ---@class DiscordEmbed
local Footer = {} ---@class DiscordFooter
local Image = {} ---@class DiscordImage
local Thumbnail = {} ---@class DiscordThumbnail
local Video = {} ---@class DiscordVideo
local Provider = {} ---@class DiscordProvider
local Author = {} ---@class DiscordAuthor
local Field = {} ---@class DiscordField
local Webhook = {} ---@class DiscordWebhook

-- Utils
local function handleArguments(functionName, items)
    for index, data in pairs(items) do
        local badType = true
        local typeOrClass
        for _, typ in pairs(data.allowedTypes) do
            if typeof(data.item) == typ then
                typeOrClass = "type"
                badType = false
                break
            elseif data.class and (getmetatable(data.item).__class == typ) then
                typeOrClass = "class"
                badType = false
                break
            end
        end
        if badType then
            warn("bad argument #" .. index .. " to '" .. functionName .. "' (" .. data.allowedTypes[1] .. " expected, got " .. (data.class and getmetatable(data.item)._class or type(data.item)) .. ")", 2)
            break
        end
    end
end

local function rgbToHex(r, g, b)
    return ("0x%x%x%x"):format(r * 255, g * 255, b * 255)
end

-- Webhook Constructor

---@param url string
---@return DiscordWebhook
function Discord:NewWebhook(url)
    handleArguments("NewWebhook", { { item = url, allowedTypes = { "string" } } })

    local webhook = setmetatable({}, { __index = Webhook, __class = "Webhook" })

    webhook.url = url

    return webhook
end

-- Webhook Methods

---@param message DiscordMessage
---@return boolean,string Success flag, and error message if any
function Webhook:Send(message)
    handleArguments("Send", { { item = message, allowedTypes = { "Message" }, class = true } })

    local http = game:GetService("HttpService")

    local data = {
        content = message:GetContent(),
        username = message:GetUsername(),
        avatar_url = message:GetAvatarUrl(),
        tts = message:GetTTS(),
        embeds = {}
    }

    for _, embed in pairs(message:GetEmbeds()) do
        local fields = {}
        for _, field in pairs(embed:GetFields()) do
            table.insert(fields, {
                name = field:GetName(),
                value = field:GetValue(),
                inline = field:GetInline()
            })
        end
        table.insert(data.embeds, {
            title = embed:GetTitle(),
            description = embed:GetDescription(),
            url = embed:GetUrl(),
            color = embed:GetColor(),
            footer = { text = (embed:GetFooter() ~= nil and embed:GetFooter():GetText() or nil), icon_url = (embed:GetFooter() ~= nil and embed:GetFooter():GetIconUrl() or nil) },
            image = { url = (embed:GetImage() ~= nil and embed:GetImage():GetUrl() or nil) },
            thumbnail = { url = (embed:GetThumbnail() ~= nil and embed:GetThumbnail():GetUrl() or nil) },
            video = { url = (embed:GetVideo() ~= nil and embed:GetVideo():GetUrl() or nil) },
            provider = { name = (embed:GetProvider() ~= nil and embed:GetProvider():GetName() or nil), url = (embed:GetProvider() ~= nil and embed:GetProvider():GetUrl() or nil) },
            author = { name = (embed:GetAuthor() ~= nil and embed:GetAuthor():GetName() or nil), url = (embed:GetAuthor() ~= nil and embed:GetAuthor():GetUrl() or nil), icon_url = (embed:GetAuthor() ~= nil and embed:GetAuthor():GetIconUrl() or nil) },
            fields = fields
        })
    end

    local success, err = pcall(function()
        http:PostAsync(self.url, http:JSONEncode(data))
    end)

    return success, err
end

-- Message Constructor

---@return DiscordMessage
function Discord:NewMessage()
    local self = setmetatable({}, { __index = Message, __class = "Message" })

    self.content = ""
    self.username = nil
    self.avatar_url = nil
    self.tts = false

    self.embeds = {}

    return self
end

-- Message Methods

---@param text string
---@return DiscordMessage
function Message:SetContent(text)
    handleArguments("SetContent", { { item = text, allowedTypes = { "string", "number" } } })
    self.content = tostring(text)
    return self
end

---@param username string
---@return DiscordMessage
function Message:SetUsername(username)
    handleArguments("SetUsername", { { item = username, allowedTypes = { "string", "number" } } })
    self.username = tostring(username)
    return self
end

---@param avatarUrl string
---@return DiscordMessage
function Message:SetAvatarUrl(avatarUrl)
    handleArguments("SetAvatarUrl", { { item = avatarUrl, allowedTypes = { "string" } } })
    self.avatar_url = avatarUrl
    return self
end

---@param tts boolean
---@return DiscordMessage
function Message:SetTTS(tts)
    handleArguments("SetTTS", { { item = tts, allowedTypes = { "boolean" } } })
    self.tts = tts
    return self
end

---@return string
function Message:GetContent()
    return self.content
end

---@return string
function Message:GetUsername()
    return self.username
end

---@return string
function Message:GetAvatarUrl()
    return self.avatar_url
end

---@return boolean
function Message:GetTTS()
    return self.tts
end

---@return DiscordEmbed[]
function Message:GetEmbeds()
    return self.embeds
end

-- Embed Constructor

---@param title string
---@param description string
---@return DiscordEmbed
function Message:AddEmbed(title, description)
    handleArguments("AddEmbed", { { item = title, allowedTypes = { "string", "number" } }, { item = description, allowedTypes = { "string", "number", "nil" } } })

    local embed = setmetatable({}, { __index = Embed, __class = "Embed" })

    embed.title = tostring(title)
    embed.description = (description == nil and nil or tostring(description))
    embed.url = nil
    embed.color = 0xffffff
    embed.footer = nil
    embed.image = nil
    embed.thumbnail = nil
    embed.video = nil
    embed.provider = nil
    embed.author = nil

    embed.fields = {}

    self.embeds[#self.embeds + 1] = embed
    return embed
end

----// Embed Methods

---@param title string
---@return DiscordEmbed
function Embed:SetTitle(title)
    handleArguments("SetTitle", { { item = title, allowedTypes = { "string", "number" } } })
    self.title = tostring(title)
    return self
end

---@param description string
---@return DiscordEmbed
function Embed:SetDescription(description)
    handleArguments("SetDescription", { { item = description, allowedTypes = { "string", "number" } } })
    self.description = tostring(description)
    return self
end

---@param url string
---@return DiscordEmbed
function Embed:SetUrl(url)
    handleArguments("SetTitle", { { item = url, allowedTypes = { "string" } } })
    self.url = url
    return self
end

---@param hexNumber number
---@return DiscordEmbed
function Embed:SetColor(hexNumber)
    handleArguments("SetColor", { { item = hexNumber, allowedTypes = { "number" } } })
    self.color = hexNumber
    return self
end

-- Footer Constructor

---@param text string
---@param iconUrl string
---@return DiscordFooter
function Embed:SetFooter(text, iconUrl)
    handleArguments("SetFooter", { { item = text, allowedTypes = { "string", "number" } }, { item = iconUrl, allowedTypes = { "string", "nil" } } })

    local footer = setmetatable({}, { __index = Footer, __class = "Footer" })

    footer.text = tostring(text)
    footer.icon_url = iconUrl

    self.footer = footer

    return footer
end

-- Footer Methods

---@param text string
---@return DiscordFooter
function Footer:SetText(text)
    handleArguments("SetText", { { item = text, allowedTypes = { "string", "number" } } })
    self.text = tostring(text)
    return self
end

---@param iconUrl string
---@return DiscordFooter
function Footer:SetIconUrl(iconUrl)
    handleArguments("SetIconUrl", { { item = iconUrl, allowedTypes = { "string" } } })
    self.icon_url = iconUrl
    return self
end

---@return string
function Footer:GetText()
    return self.text
end

---@return string
function Footer:GetIconUrl()
    return self.icon_url
end

-- Image Constructor

---@param imageUrl string
---@return DiscordImage
function Embed:SetImage(imageUrl)
    handleArguments("SetImage", { { item = imageUrl, allowedTypes = { "string" } } })

    local image = setmetatable({}, { __index = Image, __class = "Image" })

    image.url = imageUrl

    self.image = image

    return image
end

-- Image Methods

---@param url string
---@return DiscordImage
function Image:SetUrl(url)
    handleArguments("SetUrl", { { item = url, allowedTypes = { "string" } } })
    self.url = url
    return self
end

---@return string
function Image:GetUrl()
    return self.url
end

-- Thumbnail Constructor

---@param thumbnailUrl string
---@return  DiscordThumbnail
function Embed:SetThumbnail(thumbnailUrl)
    handleArguments("SetThumbnail", { { item = thumbnailUrl, allowedTypes = { "string" } } })

    local thumbnail = setmetatable({}, { __index = Thumbnail, __class = "Thumbnail" })

    thumbnail.url = thumbnailUrl

    self.thumbnail = thumbnail

    return thumbnail
end

-- Thumbnail Methods

---@param url string
---@return DiscordThumbnail
function Thumbnail:SetUrl(url)
    handleArguments("SetUrl", { { item = url, allowedTypes = { "string" } } })
    self.url = url
    return self
end

---@return string
function Thumbnail:GetUrl()
    return self.url
end

-- Video Constructor

---@param url string
---@return DiscordVideo
function Embed:SetVideo(url)
    handleArguments("SetVideo", { { item = url, allowedTypes = { "string" } } })

    local video = setmetatable({}, { __index = Video, __class = "Video" })

    video.url = url

    self.video = video

    return video
end

-- Video Methods

---@param url string
---@return DiscordVideo
function Video:SetUrl(url)
    handleArguments("SetUrl", { { item = url, allowedTypes = { "string" } } })
    self.url = url
    return self
end

---@return string
function Video:GetUrl()
    return self.url
end

-- Provider Constructor

---@param name string
---@param url string
---@return DiscordProvider
function Embed:SetProvider(name, url)
    handleArguments("SetProvider", { { item = name, allowedTypes = { "string", "number" } }, { item = url, allowedTypes = { "string", "nil" } } })

    local provider = setmetatable({}, { __index = Provider, __class = "Provider" })

    provider.name = tostring(name)
    provider.url = url

    self.provider = self

    return provider
end

-- Provider Methods

---@param name string
---@return DiscordProvider
function Provider:SetName(name)
    handleArguments("SetName", { { item = name, allowedTypes = { "string", "number" } } })
    self.name = tostring(name)
    return self
end

---@param url string
---@return DiscordProvider
function Provider:SetUrl(url)
    handleArguments("SetUrl", { { item = url, allowedTypes = { "string" } } })
    self.url = url
    return self
end

---@return string
function Provider:GetName()
    return self.name
end

---@return string
function Provider:GetUrl()
    return self.url
end

-- Author Constructor

---@param name string
---@param url string
---@param iconUrl string
---@return DiscordAuthor
function Embed:SetAuthor(name, url, iconUrl)
    handleArguments("SetAuthor", { { item = name, allowedTypes = { "string", "number" } }, { item = url, allowedTypes = { "string", "nil" } } })

    local author = setmetatable({}, { __index = Author, __class = "Author" })

    author.name = tostring(name)
    author.url = url
    author.icon_url = iconUrl

    self.author = author

    return author
end

-- Author Methods

---@param name string
---@return DiscordAuthor
function Author:SetName(name)
    handleArguments("SetName", { { item = name, allowedTypes = { "string", "number" } } })
    self.name = tostring(name)
    return self
end

---@param url string
---@return DiscordAuthor
function Author:SetUrl(url)
    handleArguments("SetUrl", { { item = url, allowedTypes = { "string" } } })
    self.url = url
    return self
end

---@param iconUrl string
---@return DiscordAuthor
function Author:SetIconUrl(iconUrl)
    handleArguments("SetIconUrl", { { item = iconUrl, allowedTypes = { "string" } } })
    self.icon_url = iconUrl
    return self
end

---@return string
function Author:GetName()
    return self.name
end

---@return string
function Author:GetUrl()
    return self.url
end

---@return string
function Author:GetIconUrl()
    return self.icon_url
end

-- Field Constructor

---@param name string
---@param value string
---@param inline boolean
---@return DiscordField
function Embed:AddField(name, value, inline)
    handleArguments("SetAuthor", { { item = name, allowedTypes = { "string", "number" } }, { item = value, allowedTypes = { "string", "number" } }, { item = inline, allowedTypes = { "boolean", "nil" } } })

    local field = setmetatable({}, { __index = Field, __class = "Field" })

    field.name = tostring(name)
    field.value = tostring(value)
    field.inline = (inline == nil and false or inline)

    self.fields[#self.fields + 1] = field

    return field
end

-- Field Methods

---@param name string
---@return DiscordField
function Field:SetName(name)
    handleArguments("SetName", { { item = name, allowedTypes = { "string", "number" } } })
    self.name = tostring(name)
    return self
end

---@param value string
---@return DiscordField
function Field:SetValue(value)
    handleArguments("SetValue", { { item = value, allowedTypes = { "string", "number" } } })
    self.value = tostring(value)
    return self
end

---@param inline boolean
---@return DiscordField
function Field:SetInline(inline)
    handleArguments("SetInline", { { item = inline, allowedTypes = { "boolean" } } })
    self.inline = inline
    return self
end

---@return string
function Field:GetName()
    return self.name
end

---@return string
function Field:GetValue()
    return self.value
end

---@return boolean
function Field:GetInline()
    return self.inline
end

--/

---@return string
function Embed:GetTitle()
    return self.title
end

---@return string
function Embed:GetDescription()
    return self.description
end

---@return string
function Embed:GetUrl()
    return self.url
end

---@return number
function Embed:GetColor()
    return self.color
end

---@return DiscordFooter
function Embed:GetFooter()
    return self.footer
end

---@return DiscordImage
function Embed:GetImage()
    return self.image
end

---@return DiscordThumbnail
function Embed:GetThumbnail()
    return self.thumbnail
end

---@return DiscordVideo
function Embed:GetVideo()
    return self.video
end

---@return DiscordProvider
function Embed:GetProvider()
    return self.provider
end

---@return DiscordAuthor
function Embed:GetAuthor()
    return self.author
end

---@return DiscordField[]
function Embed:GetFields()
    return self.fields
end

return Discord