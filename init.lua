local baseUrl = "https://raw.githubusercontent.com/uygvghgh/codebrainrot/main/"
local toggleKey = Enum.KeyCode.RightControl
local forcePlaceId = nil

local env = getgenv and getgenv() or _G
if env.codeBrainrotLoaded then
	warn("[CodeBrainrot] already loaded")
	return
end
env.codeBrainrotLoaded = true

local marketplace = game:GetService("MarketplaceService")
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local virtualInput = game:GetService("VirtualInputManager")

local function fetchModule(path)
	local okFetch, source = pcall(function()
		return game:HttpGet(baseUrl .. path)
	end)
	if not okFetch then
		return nil, source
	end

	local chunk, compileError = loadstring(source)
	if not chunk then
		return nil, compileError
	end

	local okRun, result = pcall(chunk)
	if not okRun then
		return nil, result
	end
	return result
end

local function getGameName(id)
	local name = "Unknown game"
	pcall(function()
		name = marketplace:GetProductInfo(id).Name
	end)
	return name
end

local ui, uiError = fetchModule("ui.lua")
if not ui then
	env.codeBrainrotLoaded = nil
	warn("[CodeBrainrot] failed to load ui: " .. tostring(uiError))
	return
end

local placeId = forcePlaceId or game.PlaceId
local gameName = "Studio place"
if placeId ~= 0 then
	gameName = getGameName(placeId)
end

local window = ui.createWindow({
	name = "CodeBrainrot",
	version = "",
	toggleKey = toggleKey,
})

local context = {
	notify = function(text)
		window:notify(text)
	end,
}

local gameScript = fetchModule("games/" .. tostring(placeId) .. ".lua")
local config = nil
if typeof(gameScript) == "function" then
	local ok, result = pcall(gameScript, context)
	if ok and typeof(result) == "table" then
		config = result
	else
		warn("[CodeBrainrot] game script errored: " .. tostring(result))
	end
end

local home = window:addTab("Home")
home:section("current game")
home:label(gameName)
home:label("place id  " .. tostring(placeId))
home:section("status")
if config then
	home:label("supported, open the scripts tab")
else
	home:label("no script for this game yet")
	home:label("add games/" .. tostring(placeId) .. ".lua to your repo")
end

if config then
	local scripts = window:addTab("Scripts")
	local features = config.features or {}

	if #features == 0 then
		scripts:label("no features in this script")
	end

	for _, feature in ipairs(features) do
		if feature.type == "toggle" then
			scripts:toggle(feature)
		elseif feature.type == "slider" then
			scripts:slider(feature)
		elseif feature.type == "button" then
			scripts:button(feature)
		elseif feature.type == "section" then
			scripts:section(feature.name)
		end
	end
end

local gamesTab = window:addTab("Games")
local gameList = fetchModule("games/list.lua")
if typeof(gameList) == "table" and #gameList > 0 then
	gamesTab:section("supported games")
	for _, entry in ipairs(gameList) do
		local name = entry.name
		if not name then
			name = getGameName(entry.id)
		end
		gamesTab:entry(name, tostring(entry.id))
	end
else
	gamesTab:label("couldn't load the game list")
end

local settings = window:addTab("Settings")

settings:section("performance")
settings:toggle({
	name = "disable 3d rendering",
	default = false,
	callback = function(on)
		runService:Set3dRenderingEnabled(not on)
	end,
})

local clicking = false
local clickToken = 0
local clicksPerSecond = 10

local function overWindow(position)
	local main = window.main
	if not main.Visible then
		return false
	end
	local topLeft = main.AbsolutePosition
	local size = main.AbsoluteSize
	return position.X >= topLeft.X and position.X <= topLeft.X + size.X
		and position.Y >= topLeft.Y and position.Y <= topLeft.Y + size.Y
end

local function click()
	local position = userInput:GetMouseLocation()
	if overWindow(position) then
		return
	end
	if mouse1click then
		mouse1click()
	else
		virtualInput:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
		virtualInput:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
	end
end

settings:section("auto clicker")
settings:toggle({
	name = "auto clicker",
	default = false,
	callback = function(on)
		clicking = on
		clickToken = clickToken + 1
		if not on then
			return
		end
		local myToken = clickToken
		task.spawn(function()
			while clicking and clickToken == myToken do
				click()
				task.wait(1 / clicksPerSecond)
			end
		end)
	end,
})
settings:slider({
	name = "clicks per second",
	min = 1,
	max = 30,
	default = 10,
	callback = function(value)
		clicksPerSecond = value
	end,
})

local credits = window:addTab("Credits")
local creditList = fetchModule("credits.lua")
if typeof(creditList) == "table" and #creditList > 0 then
	credits:section("made by")
	for _, person in ipairs(creditList) do
		credits:entry(person.name, person.role or "")
	end
else
	credits:label("couldn't load credits")
end

window:notify("loaded, press " .. toggleKey.Name .. " to hide")
