---@class DiscordConfig
---@field enabled boolean
---@field appId string
---@field largeIcon {icon: string, text: string}
---@field smallIcon? {icon: string, text: string}
---@field firstButton? {text: string, link: string}
---@field secondButton? {text: string, link: string}

local config = require('config.client').discord

-- Early return if Discord integration is disabled
if not config or not config.enabled then
	return
end

-- Validate required configuration
if not config.appId or not config.largeIcon then
	print('^1[ERROR]^7 Discord config is missing required fields (appId or largeIcon)')
	return
end

local maxPlayers = GlobalState.MaxPlayers or 64

--- Updates Discord Rich Presence with player count and name
---@param playerCount number
local function updateRichPresence(playerCount)
	if not playerCount or playerCount < 0 then
		return
	end

	local playerName = GetPlayerName(PlayerId()) or 'Player'
	local presenceText = ('%s | %s/%s'):format(playerName, playerCount, maxPlayers)

	SetRichPresence(presenceText)
end

--- Initializes Discord Rich Presence assets and buttons
local function initializeDiscordPresence()
	-- Set Discord Application ID
	SetDiscordAppId(config.appId)

	-- Set large icon (main server icon)
	if config.largeIcon.icon then
		SetDiscordRichPresenceAsset(config.largeIcon.icon)
		SetDiscordRichPresenceAssetText(config.largeIcon.text or '')
	end

	-- Set small icon (optional secondary icon)
	if config.smallIcon and config.smallIcon.icon and config.smallIcon.icon:len() > 0 then
		SetDiscordRichPresenceAssetSmall(config.smallIcon.icon)
		SetDiscordRichPresenceAssetSmallText(config.smallIcon.text or '')
	end

	-- Set action buttons (Discord allows up to 2 buttons)
	if config.firstButton and config.firstButton.text and config.firstButton.link then
		SetDiscordRichPresenceAction(0, config.firstButton.text, config.firstButton.link)
	end

	if config.secondButton and config.secondButton.text and config.secondButton.link then
		SetDiscordRichPresenceAction(1, config.secondButton.text, config.secondButton.link)
	end
end

-- Listen for player count changes from the server
AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
	-- Only process global state bag changes
	if bagName ~= 'global' then
		return
	end

	updateRichPresence(value)
end)

-- Initialize Discord Rich Presence on resource start
initializeDiscordPresence()
